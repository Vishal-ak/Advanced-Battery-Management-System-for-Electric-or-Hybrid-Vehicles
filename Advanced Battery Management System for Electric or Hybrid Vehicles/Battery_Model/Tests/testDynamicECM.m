%% ==========================================================
% testDynamicECM.m
%
% Project:
% Modeling and Simulation of a Hybrid Electric Vehicle Powertrain
%
% Tests the 1RC Equivalent Circuit Model (ECM)
% using different current profiles.
%
% Author: Vishal Mishra
%% ==========================================================

clear;
clc;
close all;

%% Load Battery Parameters

Battery = initBattery();

%% Simulation Settings

dt = 1;                 % Time step (s)
T_end = 300;            % Total simulation time (s)

t = 0:dt:T_end;

%% Select Current Profile
% Uncomment ONLY ONE profile

% Current = constantCurrent(t,8);

% Current = stepCurrent(t);

% Current = pulseCurrent(t);

Current = driveCycleCurrent(t);

%% Initial Conditions

SOC = zeros(size(t));
SOC(1) = 1.0;               % 100% SOC

Voltage = zeros(size(t));
OCV = zeros(size(t));

Vrc = 0;

%% Simulation Loop

for k = 1:length(t)

    if k > 1

        SOC(k) = coulombCounting( ...
            SOC(k-1), ...
            Current(k-1), ...
            dt, ...
            Battery.NominalCapacity);

    end

  [Voltage(k),Vrc,OCV(k)] = batteryECM(...
    SOC(k),...
    Current(k),...
    Vrc,...
    dt,...
    Battery);

end

%% Plot Current

figure

plot(t,Current,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('Current (A)')

title('Current Profile')

%% Plot Terminal Voltage

figure

plot(t,Voltage,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('Voltage (V)')

title('Terminal Voltage')

%% Plot OCV

figure

plot(t,OCV,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('OCV (V)')

title('Open Circuit Voltage')

%% Plot SOC

figure

plot(t,SOC,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('SOC')

title('State of Charge')