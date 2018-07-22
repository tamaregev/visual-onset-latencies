function [ ERPtrials, info ] = procEventsST18_block_GH(block, mode, SaveFolder, win, gammaflag, ampflag)
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI
% 18/11/2014 - used by the function procEventsST18 (in MasterScript_VOLST18)
% at L:\Experiments\durationGamma\ECOG\Original Exp\Results\ST18\VisualStream\Final Results\procEventsST18.m
% 14/12/2014 - Tamar: Added gammaflag for calculation of the squared absolute part of the hilbert transform here. Becaue it has to happen just before segmentation 
% 29/06/2017 - Tamar: thought that there was a mistake because no band pass
% filter, but - found it in the preproc part as HP and LP
%%
%%
if nargin<6
    ampflag = false;
end
     tictot = tic;
    %---------------Load block data--------------------------
    disp('loading data and events...'); tic
    load([SaveFolder 'data' block '_' mode '.mat']);
    info=data.info;
    load([info.datadir filesep 'events.mat']);
    load([info.datadir filesep 'artifacts.mat']);
    disp(['Done loading in ' num2str(toc) ' seconds'])
    %-------------- Hilbert ransform -------------------------
    if gammaflag
        disp('calculating hilbert transform...')
        if ampflag
            data.data = abs(hilbert(data.data'));
        else%power
            data.data = abs(hilbert(data.data')).^2;
        end
        data.data = data.data';
        disp('done')
    end
    %-------------- Stimulus vector---------------------------
    stim=zeros(1,length(data.data(1,:)));
    nEvents=length(EEG.events)/2;
    for i=1:2:nEvents*2
        stim(EEG.events(1,i).latency:EEG.events(1,i+1).latency)=1;
    end
    if 0
    % figure
    % subplot(2,1,1)
    % plot(stim)
    % title('stimulus')
    % ylim([-1,2])
    % subplot(2,1,2)
    % plot(stim)
    % axis([1.11*10^5 1.22*10^5 -1 2])
    % xlabel('ms')
    end
    % ----------- Artifact times vector-------------------------
    artifact_times=zeros(1,length(data.data(1,:)));
    for i=1:length(artifacts)
        artifact_times(artifacts(i,1)*1000:artifacts(i,2)*1000)=1;
    end
    if 0
    % figure
    % plot(stim)
    % title('stimulus')
    % ylim([-1,2])
    % hold on
    % plot(artifact_times,'r','LineWidth',3)
    % xlabel('ms')
    end
    % stimulus type -
    types = zeros(nEvents,1);
    for i=1:nEvents
        types(i,1)=EEG.events(1,2*i).type;
        types(i,1)=types(i,1)/10;
        types(i,1)=(types(i,1)-mod(types(i,1),10))/10;
    end
    if 0%this was for plotting and calculating stimulus properties, not necessary for the analysis.
    %--------Other stimulus properties - durations, SOA, ISI----
    % durations=zeros(nEvents,1);
    % for i=1:86
    %     durations(i)=EEG.events(1,2*i).latency-EEG.events(1,2*i-1).latency;
    % end

    %  % Create color vector -
    % mycolor = [ 0 0 1 ;0 0 0; 0 1 0; 1 0 0];
    % Cindex = zeros(length(EEG.events)/2,1);
    % for i=1:length(EEG.events)/2
    %     if types(i)==2
    %         Cindex(i)=1;
    %     elseif types(i)==4
    %         Cindex(i)=2;
    %     elseif types(i)==6
    %         Cindex(i)=3;
    %     elseif types(i)==8
    %         Cindex(i)=4;    
    %     end
    % end
    % % SOA - onset to onset interval
    % SOA=zeros(172/2-1,1);
    % for i=1:85
    %     SOA(i)=EEG.events(1,2*i+1).latency-EEG.events(1,2*i-1).latency;
    % end
    % %ISI - inter stimulus interval
    % ISI=zeros(85,1);
    % for i=1:85
    %     ISI(i)=SOA(i)-durations(i);
    % end
    % figure
    % subplot(3,1,1)
    % hold on
    % bar([1],[1],'b');
    % bar([1],[1],'k');
    % bar([1],[1],'g');
    % bar([1],[1],'r');
    % legend('Objects','Faces','Watches','Clothing - TARGET')
    % bar_h=bar(durations);
    % bar_child=get(bar_h,'Children');
    % set(bar_child,'CDataMapping','direct');
    % set(bar_child, 'EdgeColor', 'white'); % black outlines around the bars
    % set(bar_child, 'CData',Cindex);
    % colormap(mycolor);
    % hold off
    % title('durations','FontSize',14)
    % ylabel('ms')
    % subplot(3,1,2)
    % bar(SOA)
    % title('SOA','FontSize',14)
    % ylabel('ms')
    % subplot(3,1,3)
    % bar(ISI)
    % title('ISI','FontSize',14)
    % xlabel('stimulus number')
    % ylabel('ms')
    end
    % ----------ERP trials, WITHOUT TARGETS-----------------------
    ERPtrials=zeros(info.nelect,600,2); % (channels,time points,trials)
    nERP=0;
    for i=1:2:length(EEG.events)
        if types((i+1)/2)~=8
            if isempty(find(artifact_times(1, EEG.events(1,i).latency+win(1): EEG.events(1,i).latency+win(end)),1))  
                nERP=nERP+1;
                ERPtrials(:,:,nERP)=data.data(:,EEG.events(1,i).latency+win(1):EEG.events(1,i).latency+win(end));
            end
        end
    end
    %nERP
    disp(['Done events and segmentation ' block ' in ' num2str(toc(tictot)) ' sec.'])
end
