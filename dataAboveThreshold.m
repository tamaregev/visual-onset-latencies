function [ ind, ind_min, ind_max] = dataAboveThreshold( value_max, value_min, dataSig )
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI
% find the first time that data Sig passes one of two thresholds
    ind_max = find(dataSig>value_max,1);
    ind_min = find(dataSig<value_min,1);
    ind = min([ind_min ind_max]);

end

