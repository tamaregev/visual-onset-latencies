# visual-onset-latencies
Matlab code for the onset latency analysis, written by Tamar Regev, lab of prof. Leon Deouell, HUJI  .  
Ran on Matlab 2016b, Windows computer.  
This code was written specifically for analysing subject ST18.  
There were 3 recording sessions termed here blocks B12, B13 and B14.  

Data files are available on OSF -  

The structure of libraries should be as follows -  

\MainFolder\  
keep here main analysis script - MasterScript_VOLST18_GH.m and run it, section by section, from here  
(GH stands for GitHub ;))  
keep here also these functions:  
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
keep here the following functions, written by members of the lab of Prof. Leon Deouell (namely Leon Deouell, Edden Gerber and Alon Keren)  
HPF.m by Edden Gerber  
LPF.m by Edden Gerber  
remove_line_noise.m by Alon Keren    
ERPfigure.m by Leon Deouell    
figextras.m by Leon deouell    
varplot.m by Edden Gerber  

inside MainFolder download and keep the 3 data folders, available on OSF -  
B12\  
B13\  
B14\  
with all of their contents - these are the data structures.
