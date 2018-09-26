function PlotOnsetsOrderly_GH(refmode, SaveFolder, permsNumber, gammaflag, addms, ampflag)
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI
% 29 June 2017
%   uses HCNL lab functions ERPfigure.m and figextras.m for plotting -
%   Each subplot can be double clicked to open as a new figure. for other
%   functionalities of ERPfigure press h

%% 
load([SaveFolder 'ResultsBootstrap' num2str(permsNumber) '_' refmode]);
load([SaveFolder 'ERPtrialsTot_' refmode '.mat'])
load([SaveFolder 'info' refmode '.mat'])
switch refmode
    case 'CAR'
        numbers=1:info.nelect;
        addylp = 0; %add to ylablel position
    case 'CSD'
        info.CSDchannels = [info.insideLG, info.insideOstrip, info.inside_LedgeLR, info.inside_LedgeUD];
        numbers=info.CSDchannels;
        addylp = 200; %add to ylablel position
end
n_trials=size(ERPtrialsTot,3);

 Labels_Winawer_ST18
 retinotopy_chans = zeros(size(retinotopy,1),1);

for i=1:size(retinotopy,1)
    retinotopy_chans(i) = retinotopy{i,1};
end

%% Plot means orderly with CI
    subj='ST18';
    ordered=zeros(1,length(event));
    ch_ordered=zeros(1,length(event));
    onsets=[];
    for i=1:length(event)
        if(isempty(event{i}))
            ordered(i)=1000;%just a code number for not loosing and sorting lastly
            onsets(i)=nan;
        else
            event{i} = event{i}+addms;
            ordered(i)=event{i};        
            onsets(i)=event{i};
        end
    end
    [ordered, ch_ordered]=sort(ordered);
    numelectrodes= length(find(ordered~=1000));
    ch_ordered=ch_ordered(1:numelectrodes);
    %ordered are the onset events ordered 
    %ch_ordered are the channel numbers ordered
    errInterval(:,1:2)=errInterval(:,1:2)+addms;
    errInterval(errInterval(:,2)>300,2) = 300;
    
    fromx=-290;
    tox=300;
    timewin = fromx:tox;
    sampwin = timewin + 300 - addms;
    if gammaflag
        if strcmp(refmode,'CAR')
            if ampflag
                fromy = -15;
                toy = 29;
            else
                fromy = -200;
                toy = 800;
            end
        else
            if ampflag
                fromy = -32;
                toy = 64;
            else
                fromy = -1000;
                toy = 4000;
            end
        end
    else
        fromy=-50;
        toy=50;
    end
    indexplot=reshape(1:(3*(ceil(numelectrodes/3))),ceil(numelectrodes/3),3)';
    ERPfigure;

     for i=1:(3*(ceil(numelectrodes/3)))
         if(indexplot(i)<=numelectrodes)
             ch=ch_ordered(indexplot(i));             
             if event{ch}<300
                 h=subplot((round(numelectrodes/3)+1),3,i);
                 p = get(h, 'pos');
                 p(4) = p(4)+0.02;
                 p(3) = p(3)+0.01;
                 set(h, 'pos', p);
                data = reshape(ERPtrialsTot(ch,sampwin,:),length(sampwin),n_trials)';
                meanData = mean(data);len = length(meanData);
                varplot(timewin,data','ci',0.99);
                hold on
                xlim([fromx tox])
                ylim([fromy toy])
                    %other plotting options:
                    %set(gca,'xtick',[0:50:350],'ytick',[])
                    %set(gca,'XTickLabel',{'-100','-50','0','50','100','150','200','250'})
                set(gca,'YTickLabel',{}) 
                ylabel([num2str(ch) ': ' num2str(ordered(indexplot(i)),3) 'ms'],'Rotation',0.0,'FontWeight','bold','Position',[-200 -20+addylp 0])
                lb=length([fromx:0]);fromsb = 300-lb+1;
                plot(fromx:0,voltage_th_max_noise(ch,fromsb:300),'r')
                plot(fromx:0,voltage_th_min_noise(ch,fromsb:300),'r')
                plot(1:300,voltage_th_max(ch,:),'r')
                plot(1:300,voltage_th_min(ch,:),'r')
                line([0 0], [fromy toy],'Color','k')
                line([errInterval(ch,1), errInterval(ch,2)], [meanData(event{ch}+lb), meanData(event{ch}+lb)],'LineWidth',2)
                plot(event{ch},meanData(event{ch}+lb),'d','MarkerFaceColor','k');
                if ismember(ch,retinotopy_chans) 
                   text(-100,20,retinotopy{retinotopy_chans==ch,2})
                end
                hold off    
             end
         end
     end
     if gammaflag
         suptitle({['Onset latencies of Gamma-band response, ' , num2str(permsNumber) , ' permutations.' , 'Patient ' subj ], ['channel number: onset in [ms]. '  refmode]} )
         FigName = (['OLEordered_' num2str(permsNumber) 'perms_' refmode '_Gamma']);
     else
         suptitle({['Onset latencies detected via permutating noise, ' , num2str(permsNumber) , ' times.' , 'Patient ' subj ], ['channel number: onset in [ms]. '  refmode]} )
         FigName = (['OLEordered_' num2str(permsNumber) 'perms_' refmode]);
     end
     saveas(gcf,[SaveFolder FigName],'fig');
    
end

