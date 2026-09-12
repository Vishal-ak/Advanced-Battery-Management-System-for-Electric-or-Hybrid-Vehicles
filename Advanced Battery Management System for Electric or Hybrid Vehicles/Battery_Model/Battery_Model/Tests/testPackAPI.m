clc
clear
close all

%% Initialize Reference Battery Cell
% Load the reference battery-cell parameters used for
% constructing and evaluating the battery pack.

Battery = initBattery();

%% Create Battery Pack
% Construct a 13S6P battery pack using the initialized
% reference cell model.

fprintf("\n");
fprintf("=========================================\n");
fprintf("       BATTERY PACK API TEST\n");
fprintf("=========================================");

Pack = createBatteryPack(Battery,13,6);

%% Define Cell Operating Conditions
% Use the nominal cell voltage and maximum specified
% discharge current as the operating conditions for
% pack-level calculations.

CellVoltage = Battery.NominalVoltage;          % V
CellCurrent = Battery.MaxDischargeCurrent;     % A

%% Calculate Pack Electrical Parameters
% Use the Battery Pack API functions to calculate the
% pack voltage, current, power, and stored energy.

Vpack = packVoltage(CellVoltage,Pack);
Ipack = packCurrent(CellCurrent,Pack);
Power = packPower(Vpack,Ipack);
[EWh,EkWh] = packEnergy(Vpack,Pack.Capacity);

%% Display Battery Pack API Results
% Display the pack configuration and the calculated
% electrical, energy, mass, and performance parameters.

