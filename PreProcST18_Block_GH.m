function [dataCAR, dataCSD]= PreProcST18_Block_GH(block,LP,HP,deg,causalflag)
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI

% inputs: block is a string e.g. - 'B12' ...
%         LP and HP are cutoff frequencies for a low-pass and high-pass
%         filter, respectively. If no filter is wanted, insert 0.
%         deg - default is 4
%         causalflag default is false --> non causal

% outputs: data both for CAR and CSD references 

%% inputs
if ~exist('deg','var')
    deg = 4;
end
if ~exist('causalflag','var')
    causalflag = false;
end
%% get info
%--load existing -
MasterFolder = cd;
cd(block)
%--replace -
info.subject_name = 'ST18';
info.block_name = block;
info.datadir  = cd;
info.analysis_folder =  [cd filesep 'Processed_data'];
info.srate = 1000;
info.invert = -1;
info.edat_filename =     [info.datadir filesep 'edat_events_ST18_' block '.mat'];
info.saveDate = datestr(now);% Record current time.  
info.nelect =            112; % number of electrodes
info.badChannels =       [17, 63, 64, 77, 91, 95];
info.epiChannels = 	 [35, 36, 42, 43, 44, 52, 53, 100, 101, 102];

data.info = info;
clear info

data.info.excludedChannels = [data.info.badChannels data.info.epiChannels];
data.info.selectedChannels = setdiff(1:data.info.nelect, data.info.excludedChannels);
data.excludedChannels = data.info.excludedChannels;
data.selectedChannels = data.info.selectedChannels;

curdir = data.info.datadir;
cd(curdir)
%% loading raw_mat
tic
load([data.info.datadir filesep 'raw_mat' block '_1000.mat']);
disp(['Done loading raw_mat in ' num2str(toc) ' sec.'])
data.data=raw_mat(1:data.info.nelect,:);
clear raw_mat;
subj = data.info.subject_name;
block = data.info.block_name;

%% Subtract Average Baseline
means = mean(data.data')';
data.data=data.data-repmat(means, [1,length(data.data)]);
data.info.meansubtract = 'yes';

%% remove 60Hz noise 
tic
disp('removing line noise...')
data.data = remove_line_noise(data.data(:,:)', 60, data.info.srate, 10)';
disp(['Done Removing line noise in ' num2str(toc) ' sec.'])
data.info.linenoise='yes';

%% Filter
data.info.LP = LP;
data.info.HP = HP;
if LP
    % High-Pass Filter
    disp('Low-pass filter...');
    if causalflag
        data.data = single(LPF(double(data.data)',data.info.srate,LP,'causal',deg))';
    else
        data.data = single(LPF(double(data.data)',data.info.srate,LP,deg))';
    end
    disp('Done LP')
end
if HP
    disp('High-pass filter...');
    if causalflag
        data.data = single(HPF(double(data.data)',data.info.srate,HP,'causal',deg))';
    else
        data.data = single(HPF(double(data.data)',data.info.srate,HP,deg))';
    end
    disp('Done HP')
end

%% Reference:
% do both CAR and CSD and save
%%%Subtract Common Average
tic
% CAR of good channels -
CommAvg=mean(data.data(data.info.selectedChannels,:));
CommAvg=repmat(CommAvg,[data.info.nelect,1]);
data.data(:,:) = data.data(:,:) - CommAvg;
toc
dataCAR = data;
dataCAR.info.CAR = 'CAR only selectedChannels';
clear CommAvg

%%%CSD reference 
tic
disp('CSD...')
cd(MasterFolder)
[inside_Lgrid, inside_Ostrip, inside_LedgeUD, inside_LedgeLR, sides_LedgeUD, sides_LedgeLR, sides_Ostrip, cross_electrodes] = CSDelectMap;
i=0;
for elect=inside_Lgrid
    i=i+1;
    data.data(elect,:)=4*dataCAR.data(elect,:)-sum(dataCAR.data(cross_electrodes(i,1:4),:));
end   
%disp('Ostrip')
i=0;
for elect=inside_Ostrip
    i=i+1;
    data.data(elect,:)=2*dataCAR.data(elect,:)-sum(dataCAR.data(sides_Ostrip(i,1:2),:));
end
%disp('LedgeUD')
i=0;
for elect=inside_LedgeUD
    i=i+1;
    data.data(elect,:)=2*dataCAR.data(elect,:)-sum(dataCAR.data(sides_LedgeUD(i,1:2),:));
end
%disp('LedgeLR')
i=0;
for elect=inside_LedgeLR
    i=i+1;
    data.data(elect,:)=2*dataCAR.data(elect,:)-sum(dataCAR.data(sides_LedgeLR(i,1:2),:));
end

disp(['Done CSD referencing in ' num2str(toc) ' seconds'])
data.info.REF = 'CSD including edges';
data.info.insideLG = inside_Lgrid;
data.info.cross = cross_electrodes;
data.info.insideOstrip=inside_Ostrip;
data.info.sidesOstrip=sides_Ostrip;
data.info.inside_LedgeLR=inside_LedgeLR;
data.info.inside_LedgeUD=inside_LedgeUD;
data.info.sides_LedgeLR=sides_LedgeLR;
data.info.sides_LedgeUD=sides_LedgeUD;

dataCSD = data;

clear data

end
