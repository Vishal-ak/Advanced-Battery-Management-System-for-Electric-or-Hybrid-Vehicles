clc
clear
close all

%% Define Battery Pack Requirements
% Specify the required nominal voltage and battery capacity
% for the desired battery-pack application.

Voltage = 48;
Capacity = 20;

%% Generate Battery Pack Recommendations
% Evaluate the available battery-pack configurations based
% on the specified voltage and capacity requirements.
% The function returns the recommended configurations along
% with their electrical, physical, and optimization parameters.

Results = recommendPack(Voltage, Capacity);

%% Display Recommendation Results
% Display the design requirements and the evaluated battery-pack
% configurations, including voltage, capacity, weight, and score.

fprintf("\n=========================================\n");
fprintf("      Battery Pack Recommendations\n");
fprintf("=========================================\n");

fprintf("Required Voltage   : %.2f V\n", Voltage);
fprintf("Required Capacity  : %.2f Ah\n", Capacity);

fprintf("=========================================\n");

%% Display Ranked Battery Configurations
% Display the configuration, nominal voltage, nominal capacity,
% pack weight, and recommendation score for each evaluated pack.

disp(Results(:, ...
    {'Configuration',...
     'NominalVoltage_V',...
     'NominalCapacity_Ah',...
     'Weight_kg',...
     'Score'}));

fprintf("=========================================\n");