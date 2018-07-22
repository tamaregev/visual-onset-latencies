function [ event, onsets, perms, errInterval, t_values, p_max_arr, p_min_arr, minomax_arr, voltage_th_max, voltage_th_min, voltage_th_max_noise, voltage_th_min_noise] = onset_detectionST18_GH( refmode, ERPtrialsTot, permsNumber, alpha, SaveFolder, plotflag, gammaflag)
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI

% 18/11/2014 - adapted from L:\Experiments\durationGamma\ECOG\Original Exp\Results\ST18\VisualStream\fastPreProc\onset_detection.m
% for using in MasterScript
% 25/11/2014 - Tamar: changed th to voltage_th - a dynamic threshold
% tmax*SE = p_max_arr*SE
% 26/11/2014 - Tamar: changed ind_ordered to ch_ordered and more in code of
% plotting. Added - Retinotopy_ST18
% 27/11/2014 - Tamar: changed mode to refmode because mode is a matlab
% function so it caused calling her.
% 14/12/2014 - Tamar: added gammaflag as a parametr for the function, to be
% displayed on the graph.
% 25/12/2014 - Tamar: changed numbers=info.selectedChannels to
% 1:info.nelect for including bad and epileptic channels as well in the
% total calculation
%%
load([SaveFolder 'info' refmode '.mat'])
switch refmode
    case 'CAR'
        numbers=1:info.nelect;
    case 'CSD'
        info.CSDchannels = [info.insideLG, info.insideOstrip, info.inside_LedgeLR, info.inside_LedgeUD];
        numbers=info.CSDchannels;
end

%%-----------Assemble data with t ms baseline before event onset
n_trials=size(ERPtrialsTot,3);
%t=100;
%ERPtrials_forplot = ERPtrialsTot(:,(301-t):600,:);

% Separate noise and responses
NoiseResponse={ERPtrialsTot(:,1:300,:)  ERPtrialsTot(:,301:600,:)};

% for ALL CHANNELS bootstrapping noise!!
 
event={};
perms=permsNumber;
t_values=[];
p_max_arr=zeros(info.nelect,1);
p_min_arr=zeros(info.nelect,1);
V_max_arr=zeros(info.nelect,1);
V_min_arr=zeros(info.nelect,1);
voltage_th_max = zeros(info.nelect,300);
voltage_th_max_noise = zeros(info.nelect,300);
voltage_th_min = zeros(info.nelect,300);
voltage_th_min_noise =zeros(info.nelect,300);
minomax_arr=zeros(info.nelect,1);

for numelect = numbers
    disp(numelect)
    tic
    n_trials=size(NoiseResponse{1},3);
    Data1=reshape(NoiseResponse{1}(numelect,:,:),300,n_trials)';
    Data2=reshape(NoiseResponse{2}(numelect,:,:),300,n_trials)';
    Data2_mean=mean(Data2,1);% response ERP
    [~, ~, value_max, value_min] = permutations_noiseST18_GH( Data1,perms,alpha);
    % store into an array for later use
    [~,~,~,stats] = ttest(Data2);
    dataSig=stats.tstat;
    t_values(numelect,:) = dataSig;
    p_max_arr(numelect,:) = value_max;%tmax values for alpha
    p_min_arr(numelect,:) = value_min;%tmin values for alpha
    [ ind, ind_min, ind_max ] = dataAboveThreshold( value_max, value_min, dataSig );
    if ind==ind_max
        minomax_arr(numelect,:) = 1;
    elseif ind==ind_min
        minomax_arr(numelect,:)=0;
    end
    event{numelect}=ind;
    disp(['Done bootstrapping channel ' num2str(numelect) ' in ' num2str(toc) ' sec.'])
    %end
end
%% Estimate error from CI
%     figure
tic
errInterval=zeros(info.nelect,2);%[minIntervalBorder maxIntervalBorder]
for numelect = numbers
    disp(num2str(numelect))
    if ~isempty(event{numelect})
        data = reshape(ERPtrialsTot(numelect,301:600,:),300,n_trials)';
        data_noise = reshape(ERPtrialsTot(numelect,1:300,:),300,n_trials)';
        data_mean = nanmean(data);
        %th=repmat(data_mean(event{numelect}),1,300);
        voltage_th_max(numelect,:) = p_max_arr(numelect,1)*std(data)/sqrt(size(data,1));
        voltage_th_max_noise(numelect,:) = p_max_arr(numelect,1)*std(data_noise)/sqrt(size(data,1));
        voltage_th_min(numelect,:) = p_min_arr(numelect,1)*std(data)/sqrt(size(data,1));
        voltage_th_min_noise(numelect,:) = p_min_arr(numelect,1)*std(data_noise)/sqrt(size(data,1));

        if minomax_arr(numelect) 
            voltage_th = voltage_th_max(numelect,:);
        else
            voltage_th = voltage_th_min(numelect,:);
        end
        [~,~,CImat] = ttest(data,0, alpha);  
        LowerEBars= CImat(1,:);
        %find zerocrossing
        signum = sign(LowerEBars-voltage_th);	% get sign	
        signum(LowerEBars-voltage_th ==0) = 1;	% set sign of exact data zeros to positiv	
        LowerCrosses=find(diff(signum)~=0)+1;	% get zero crossings by diff ~= 0	
        
        UpperEBars= CImat(2,:);
        %find zerocrossing
        signum = sign(UpperEBars-voltage_th);	% get sign	
        signum(UpperEBars-voltage_th ==0) = 1;	% set sign of exact data zeros to positiv	
        UpperCrosses=find(diff(signum)~=0)+1;	% get zero crossings by diff ~= 0

        %find closest points to onset from down+up
        AllCrosses = [LowerCrosses UpperCrosses];
        BeforeCrosses = AllCrosses((AllCrosses-event{numelect})<= 0);
        AfterCrosses = AllCrosses((AllCrosses-event{numelect}) >= 0);
        if ~isempty(AfterCrosses)
            errInterval(numelect,2)=event{numelect}+min(AfterCrosses-event{numelect});
        else
            errInterval(numelect,2)=300;
            disp('no upper limit to error')
            %pause
        end
        if ~isempty(BeforeCrosses)
            errInterval(numelect,1)=event{numelect}+max(BeforeCrosses-event{numelect});
        else
            errInterval(numelect,1)=20;%why 20?
            disp('no lower limit to error')
            %pause
        end
        errInterval(numelect,3)=(errInterval(numelect,2)-errInterval(numelect,1))/2;
        
        %ERPplusEBarSolidFill2(data, 1:300, [1 0 1], '-', 0.65,0.01) ;
%         subplot 122
%         varplot(1:300,data','ci',0.99)
%         hold on
%         plot(voltage_th_max(numelect,:),'r')
%         plot(voltage_th_min(numelect,:),'r')
%         title(['channel ' num2str(numelect) ', minomax - ' num2str(minomax_arr(numelect))])
%         plot(UpperCrosses,voltage_th(UpperCrosses),'*','MarkerSize',16,'Color','g')
%         plot(LowerCrosses,voltage_th(LowerCrosses),'*','MarkerSize',16,'Color','g')
%         plot(errInterval(numelect,1),voltage_th(errInterval(numelect,1)),'.','MarkerSize',16,'Color','k')
%         plot(errInterval(numelect,2),voltage_th(errInterval(numelect,2)),'.','MarkerSize',16,'Color','k')
%         plot(event{numelect},data_mean(event{numelect}),'.','MarkerSize',16,'Color','k')
%         hold off
%         subplot 121
%         varplot(1:300,reshape(ERPtrialsTot(numelect,1:300,:),300,n_trials),'ci',0.99)
%         hold on
%         title(['noise'])
%         plot(voltage_th_max_noise(numelect,:),'r')
%         plot(voltage_th_min_noise(numelect,:),'r')
%         hold off
%         ERPfigure(gcf)
%         pause
    %close
    end
    
end
display(['done error estimation in ' num2str(toc) ' sec.'])
end %end the function