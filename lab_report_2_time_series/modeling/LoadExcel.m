clear,clc
addpath C:\Users\Bunker\Documents\MATLAB\functions

w=xlsread('model values.xlsx','T3:T28');
exp=xlsread('model values.xlsx','U3:U28');
s=xlsread('model values.xlsx','C3:L28');

d(:,:,1)=xlsread('Inhib Values.xlsx','0hr','B3:K26');
d(:,:,2)=xlsread('Inhib Values.xlsx','0hr','M3:V26');
d(:,:,3)=xlsread('Inhib Values.xlsx','0hr','X3:AG26');
d(:,:,4)=xlsread('Inhib Values.xlsx','0hr','AI3:AR26');
d(:,:,5)=xlsread('Inhib Values.xlsx','0hr','AT3:BC26');
d(:,:,6)=xlsread('Inhib Values.xlsx','0hr','BE3:BN26');

err(:,:,1)=xlsread('Inhib Values.xlsx','0hr','B29:K52');
err(:,:,2)=xlsread('Inhib Values.xlsx','0hr','M29:V52');
err(:,:,3)=xlsread('Inhib Values.xlsx','0hr','X29:AG52');
err(:,:,4)=xlsread('Inhib Values.xlsx','0hr','AI29:AR52');
err(:,:,5)=xlsread('Inhib Values.xlsx','0hr','AT29:BC52');
err(:,:,6)=xlsread('Inhib Values.xlsx','0hr','BE29:BN52');

conc(1,:)=xlsread('Inhib Values.xlsx','0hr','B2:K2');
conc(2,:)=xlsread('Inhib Values.xlsx','0hr','M2:V2');
conc(3,:)=xlsread('Inhib Values.xlsx','0hr','X2:AG2');
conc(4,:)=xlsread('Inhib Values.xlsx','0hr','AI2:AR2');
conc(5,:)=xlsread('Inhib Values.xlsx','0hr','AT2:BC2');
conc(6,:)=xlsread('Inhib Values.xlsx','0hr','BE2:BN2');


%%