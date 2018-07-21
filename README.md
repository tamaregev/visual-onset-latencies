# visual-onset-latencies
Matlab code for the onset latency analysis.

This code was written specifically for analysing subject ST18.


There were 3 recording sessions termed here blocks B12, B13 and B14.

Data files are available on OSF -

The structure of libraries should be as follows -

MainFolder\
run MasterScript.m from here, and keep here also these functions:
PreProcST18_Block_GH.m (GH stands for GitHub ;))
procEventsST18_GH.m
procEventsST18_Block_GH.m
onset_detectionST18_GH.m
permutations_noiseST18_GH.m
dataAboveThreshold.m
CSDelectMap.m
Retinotopy_ST18.m

inside MainFolder create folder - HCNL Lab functions\
keep here the following functions, written by members of the lab of Prof. Leon Deouell
HPF.m
LPF.m
remove_line_noise.m

inside MainFolder download and keep the 3 folders - 

B12\
B13\
B14\
with all of their contents - these are the data structures.
