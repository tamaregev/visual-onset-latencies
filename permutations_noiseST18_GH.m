function [ p_max, p_min, value_max, value_min] = permutations_noiseST18_GH(Data1,perms,alpha)
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI

%%
hist_vector_max=zeros(perms,1);
hist_vector_min=zeros(perms,1);
for i=1:perms
    selection=randi(size(Data1,1),size(Data1,1),1);
    group=Data1(selection,:);
    [~,~,~,stats1] = ttest(group);
    hist_vector_max(i)=max(stats1.tstat);
    hist_vector_min(i)=min(stats1.tstat);
end
[n_max,xout_max] = hist(hist_vector_max,min(hist_vector_max):0.01:max(hist_vector_max));
[n_min,xout_min] = hist(hist_vector_min,min(hist_vector_min):0.01:max(hist_vector_min));
cumulative_max = cumsum(n_max./sum(n_max));
cumulative_min = cumsum(n_min./sum(n_min));
p_max = find(cumulative_max>(1-alpha),1,'first');
p_min = find(cumulative_min<alpha,1,'last');
value_min = xout_min(p_min);
value_max = xout_max(p_max);
end

