clc
clear
close all

%% Initialize Reference Battery Cell
% Load the reference lithium-ion cell parameters and model data.

Battery = initBattery();

%% Define Battery Pack Configuration
% Specify the number of cells connected in series (Ns)
% and parallel (Np).
%
% Ns determines the pack voltage, while Np determines
% the pack capacity.

Ns = 80;
Np = 2;

%% Create Battery Pack
% Construct the battery pack using the selected cell model
% and the specified series-parallel configuration.

Pack = createBatteryPack(Battery,Ns,Np);

%% Display Battery Pack
% Display the calculated electrical and physical parameters
% of the constructed battery pack.

disp(Pack)