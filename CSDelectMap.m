function [inside_Lgrid, inside_Ostrip, inside_LedgeUD, inside_LedgeLR, sides_LedgeUD, sides_LedgeLR, sides_Ostrip, cross_electrodes] = CSDelectMap( )
%% written by Tamar Regev, lab of prof. Leon Deouell, HUJI
%Electrode mapping for CSD reference
%try pushing

inside_Lgrid=[10:15 18:23 26:31 34:39 42:47 50:55];
inside_Ostrip=[66:69];
inside_LedgeUD=[2:7 58:63];
inside_LedgeLR=[9 17 25 33 41 49 16 24 32 40 48 56];

sides_LedgeUD=zeros(length(inside_LedgeUD),2);
sides_LedgeUD(:,1)=inside_LedgeUD-1;
sides_LedgeUD(:,2)=inside_LedgeUD+1;

sides_LedgeLR=zeros(length(inside_LedgeLR),2);
sides_LedgeLR(:,1)=inside_LedgeLR-8;
sides_LedgeLR(:,2)=inside_LedgeLR+8;

sides_Ostrip=zeros(length(inside_Ostrip),2);
sides_Ostrip(:,1)=inside_Ostrip-1;
sides_Ostrip(:,2)=inside_Ostrip+1;

cross_electrodes = zeros(length(inside_Lgrid),4);
cross_electrodes(:,1)=inside_Lgrid-1; cross_electrodes(:,2)=inside_Lgrid+1;
cross_electrodes(:,3)=inside_Lgrid-8;cross_electrodes(:,4)=inside_Lgrid+8;

end

