clc
clear
close all

Voltage = 48;

Capacity = 20;

Results = recommendPack(Voltage,Capacity);

fprintf("\n=========================================\n");
fprintf(" Battery Pack Recommendations\n");
fprintf("=========================================\n");

disp(Results(:,...
{'Configuration',...
'NominalVoltage_V',...
'NominalCapacity_Ah',...
'Weight_kg',...
'Score'}));