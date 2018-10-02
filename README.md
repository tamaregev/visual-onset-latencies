# visual-onset-latencies
Matlab code by Tamar Regev, lab of prof. Leon Deouell, HUJI.  
Ran on Matlab 2016b, Windows computer.

Associated with the paper -
Regev, T. I., Winawer, J., Gerber, E. M., Knight, R. T., & Deouell, L. Y. (2018). Human posterior parietal cortex responds to visual stimuli as early as peristriate occipital cortex. European Journal of Neuroscience. http://doi.org/10.1111/ejn.14164

This code was written in order to compute visual onset latencies in a specific ECoG patient.
There were 3 recording sessions termed here blocks B12, B13 and B14.

Data files are available at - 
http://doi.org/10.17605/OSF.IO/X3E9R  

In order to reproduce the analysis, download all scripts in this repository, and the data files from OSF.
The structure of libraries should be as follows -  

\MainFolder\  
save here main analysis script - MasterScript_VOLST18_GH.m and run it, section by section. 
save here also these functions:  
PreProcST18_Block_GH.m    
procEventsST18_GH.m  
procEventsST18_Block_GH.m  
onset_detectionST18_GH.m  
permutations_noiseST18_GH.m  
dataAboveThreshold.m  
CSDelectMap.m  
Labels_Winawer_ST18.m  
PlotOnsetsOrderly_GH.m  

inside MainFolder create folder -  
\HCNL Lab functions\  
save here the following functions, written by members of the lab of Prof. Leon Deouell   
HPF.m by Edden Gerber  
LPF.m by Edden Gerber  
remove_line_noise.m by Alon Keren    
ERPfigure.m by Leon Deouell    
figextras.m by Leon deouell    
varplot.m by Edden Gerber  
(see 'HCNL Lab functions' folder on the repository)  
  
download and save in the \MainFolder\ the 3 data folders -  
B12\  
B13\  
B14\  
with all of their contents - these are the data structures.
http://doi.org/10.17605/OSF.IO/X3E9R  

The data is a lightly processed version of the raw data, downsampled from the recording samplerate of 3051.76 to 1000 Hz using the Matlab resample function and rat:
[p q] = rat(1000/3051.76);
raw_mat = resample(data,p,q);

for any further requests, please contact tamaregev [you know what comes here] gmail [and here].
