clc
clear
close all

%% Initialize Cell

Battery = initBattery();

%% Create Pack

Ns = 80;
Np = 2;

Pack = createBatteryPack(Battery,Ns,Np);

%% Display

disp(Pack)