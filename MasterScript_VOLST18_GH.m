 % Master script - Visual Onset Latencies analysis for ST18 data
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI

% 17/11/2014 - created this script for unifying all analysis for the paper.
% The purpose is to reproduce the analysis, possibly changing parameters:
% - the filter (BP 0.1-200 to none)
% - add dynamic threshold to the temporal error calculation and figures
% - reproduce all figures
% 27/11/2014 - Tamar: changed mode to refmode because mode is a matlab
% function so it caused calling her.
% 14/12/2014 - Tamar: added the gammaflag - to add a hilbert transform when
% I want to do the analysis on gamma band. The transform is done right
% before the segmentation, and a HP cutoff should be chosen in the preproc
% params.
% 9/7/2017 - Tamar: I added parameters deg and causalflag to control params
% of the filters. defaults - deg = 4, causalflag = false.
%% Definitions:
blocks = {'B12','B13','B14'};%this analysis is specific to the data of Patient ST18

% Folders -
MasterFolder = cd;%be in the folder where all scripts are
addpath 'HCNL Lab functions';

% parameters:
gammaflag = false; %if you wanna run the analysis on gamma signals
permsNumber = 10000;%number of permutations
%create a folder to save all data:
switch gammaflag
    case false
        LP=0;HP=0;%no filter. Can change to include HP and LP filters
        SaveFolderName = ['12-Jul-2017_nofilter_' num2str(permsNumber)];
    case true
        %filter params:
        LP=0;HP=30;%filterring happens in preproc, and hilbert transform only in the procEventsST18_block.
        causalflag = true;deg = 4;
        ampflag = true;
        SaveFolderName = ['14-Aug-2017_gammaAmp_causalHP' num2str(HP) '_deg' num2str(deg) '_' num2str(permsNumber)];%folder for gamma with informative text
end

mkdir(MasterFolder,SaveFolderName);
SaveFolder = [MasterFolder filesep SaveFolderName filesep];
refmodes={'CAR', 'CSD'};

if ~exist('deg','var')
    deg = 4;
end
if ~exist('causalflag','var')
    causalflag = false;
end

%% Pre processing
% Scripts - CreateRawMatrix_B12.m created raw matrices:
% raw_mat was saved as raw_matB12_1000.mat in the ST18_B12 folder
% same for other blocks
preproc = tic;

for b = 1:length(blocks)
    tic
    block = blocks{b};
    [dataCAR, dataCSD] = PreProcST18_Block_GH(block, LP, HP, deg, causalflag);
    data = dataCAR;
    save([SaveFolder 'data' block '_CAR'],'data')
    if b==1
        %save info
        info = data.info;
        save([SaveFolder filesep 'infoCAR'],'info'); clear info
    end
    clear dataCAR data
    data = dataCSD;
    if b==1
        %save info
        info = data.info;
        save([SaveFolder filesep 'infoCSD'],'info'); clear info
    end
    save([SaveFolder 'data' block '_CSD'],'data')
    clear dataCSD data
    disp(['Done PreProc and save block ' block ' in ' num2str(toc) ' sec.'])
end

disp(['Done all pre processing in ' num2str(toc(preproc)) ' sec.'])
%Done all pre processing in 417.1565 sec.

%% Events, Segmentation
cd(MasterFolder)
if ~exist('ampflag','var')
    ampflag = false;
end
ticevents = tic;
for m=1:length(refmodes)
%for m=1
    refmode = refmodes{m};
    disp(['calculating events and segmenting ' refmode '...'])
    [ ERPtrialsTot ] = procEventsST18_GH(blocks, refmode, SaveFolder, gammaflag, ampflag);
    disp(['saving ERPtrialsTot_' refmode '.mat...'])
    save([SaveFolder 'ERPtrialsTot_' refmode '.mat'] , 'ERPtrialsTot', 'gammaflag')
    %clear ERPtrialsTot
end
disp(['Done all events and segmentation in ' num2str(toc(ticevents)) ' sec.'])
%Done all events and segmentation in 99.7653 sec.

%% Onset latency analysis
cd(MasterFolder)
tictot=tic;
alpha = 0.01;
plotflag = true;%for generating plot of all responses ordered within the function onset_detectionST18_GH
for m=1:length(refmodes)
%for m = 1 %if only CAR
    refmode = refmodes{m};
    disp(['Onset latency analysis ' refmode ' ...'])
    load([SaveFolder 'ERPtrialsTot_' refmode '.mat'])
    [ event, onsets, perms, errInterval, t_values, p_max_arr, p_min_arr, minomax, voltage_th_max, voltage_th_min, voltage_th_max_noise, voltage_th_min_noise] = onset_detectionST18_GH( refmode, ERPtrialsTot, permsNumber, alpha, SaveFolder, plotflag, gammaflag); 
    save([SaveFolder 'ResultsBootstrap' num2str(permsNumber) '_' refmode],'event', 'onsets', 'perms', 'errInterval', 't_values', 'p_max_arr', 'p_min_arr', 'minomax', 'voltage_th_max', 'voltage_th_min', 'voltage_th_max_noise', 'voltage_th_min_noise','gammaflag');
    clear ERPtrialsTot event onsets perms errInterval t_values p_max_arr p_min_arr minomax voltage_th_max voltage_th_min voltage_th_max_noise voltage_th_min_noise
end
disp(['Done all onset latency analysis in ' num2str(toc(tictot)) ' sec.'])
%Done all onset latency analysis in 4920.9112 sec.

%% plot onsets and signals orderly
addms = 5;
%permsNumber = 10000;
for m=1:length(refmodes)
    refmode = refmodes{m};
    %load([SaveFolder 'ResultsBootstrap' num2str(permsNumber) '_' refmode]);
    PlotOnsetsOrderly_GH(refmode, SaveFolder, permsNumber, gammaflag, addms, ampflag );
    set(gcf,'name',[refmode '_' SaveFolderName],'NumberTitle', 'off')
end

%% create excell
addms = 5;

% Load retinotopy
Labels_Winawer_ST18

retinotopy_chans = zeros(size(retinotopy,1),1);
for i=1:size(retinotopy,1)
    retinotopy_chans(i) = retinotopy{i,1};
end

for m=1:length(refmodes)
%for m = 2
    refmode = refmodes{m};
    filename = ['ResultsTable_' refmode '.xls'];
%    load([SaveFolder filesep 'ResultsBootstrap4000_' refmode '.mat'])
    load([SaveFolderName filesep 'ResultsBootstrap' num2str(permsNumber) '_' refmode '.mat'])
%     load([SaveFolder filesep 'info' refmode])
    load([SaveFolderName filesep 'info' refmode])
    switch refmode
        case 'CAR'
            usedElectrodes = 1:112;
        case 'CSD'
            usedElectrodes = [info.insideLG, info.insideOstrip, info.inside_LedgeLR, info.inside_LedgeUD];
            usedElectrodes = sort(usedElectrodes);
    end
    A=cell(length(usedElectrodes)+1,4);
    A(1,:)={'electrode number','electrode label','OLE [ms]','temporal error estimate [ms]';};
    for i = 1:length(usedElectrodes)
        ch=usedElectrodes(i);
        A(i+1,1)={ch};
        if ismember(ch,retinotopy_chans)
                A(i+1,2)=retinotopy(retinotopy_chans==ch,2);
        end
        if ismember(ch,info.badChannels)
            A(i+1,2)={[A{i+1,2} ' bad']};
        elseif ismember(ch,info.epiChannels)
            A(i+1,2)={[A{i+1,2} ' epileptic']};
        elseif ch==73
            A(i+1,2)={[A{i+1,2} ' m-fus']};
        elseif ch==78
            A(i+1,2)={[A{i+1,2} ' p-fus']}; 
        elseif ch==34
            A(i+1,2)={[A{i+1,2} ' IPS 0']}; 
        end

        A(i+1,3)={event{ch}+addms};
        if errInterval(ch,3)
            A(i+1,4)={errInterval(ch,3)};
        end
    end
    xlswrite([SaveFolderName filesep filename],A);
end