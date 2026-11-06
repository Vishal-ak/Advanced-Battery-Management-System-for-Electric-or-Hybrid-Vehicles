clc
clear
close all

%% Automatic Battery Pack Design
% Design a battery pack based on the required nominal voltage
% and capacity. The function automatically determines a suitable
% series-parallel cell configuration.

Pack = designPack(48,20);

%% Display Designed Pack
% Display the calculated battery-pack parameters and configuration.

disp(Pack)