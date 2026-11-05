%% ==========================================================
% testDynamicECM.m
%
% Project:
% Advanced Battery Management System for Electric & Hybrid Vehicles
%
% Tests the 1RC Equivalent Circuit Model (ECM)
% using time-varying battery current profiles.
%
% The script evaluates battery terminal voltage, OCV, and SOC
% under dynamic operating conditions.
%
% Author: Vishal Mishra
%% ==========================================================

clear;
clc;
close all;

%% Initialize Battery Model
% Load the reference battery-cell parameters and model data
% required for the ECM and SOC calculations.

Battery = initBattery();

%% Simulation Settings
% Define the simulation time step and total simulation duration.
% The time vector is used to evaluate the battery response
% under dynamic current conditions.

dt = 1;                 % Time step (s)
T_end = 300;            % Total simulation time (s)

t = 0:dt:T_end;

%% Select Current Profile
% Select one of the available current profiles for the dynamic
% ECM simulation. Uncomment ONLY ONE profile at a time.
%
% Constant current: fixed discharge current.
% Step current: current changes between predefined levels.
% Pulse current: periodic high-current pulses.
% Drive cycle: time-varying current representing dynamic operation.

% Current = constantCurrent(t,8);

% Current = stepCurrent(t);

% Current = pulseCurrent(t);

Current = driveCycleCurrent(t);

%% Initialize Battery State Variables
% Allocate memory for SOC, terminal voltage, and OCV.
% The initial SOC is set to 100%, and the RC polarization
% voltage is initialized to zero.

SOC = zeros(size(t));
SOC(1) = 1.0;               % Initial SOC (100%)

Voltage = zeros(size(t));
OCV = zeros(size(t));

Vrc = 0;                    % Initial RC polarization voltage (V)

%% Dynamic ECM Simulation
% At each time step:
% 1. Update SOC using Coulomb Counting.
% 2. Calculate terminal voltage and OCV using the 1RC ECM.
%
% The previous time-step current is used for SOC integration.

for k = 1:length(t)

    if k > 1

        SOC(k) = coulombCounting( ...
            SOC(k-1), ...
            Current(k-1), ...
            dt, ...
            Battery.DesignCapacity);

    end

    [Voltage(k), Vrc, OCV(k)] = batteryECM( ...
        SOC(k), ...
        Current(k), ...
        Vrc, ...
        dt, ...
        Battery);

end

%% Display Simulation Information
% Display the selected current profile and the main simulation
% parameters, including initial/final SOC and current range.

fprintf('\n');
fprintf('====================================================\n');
fprintf('              Dynamic ECM Simulation\n');
fprintf('====================================================\n');

fprintf('Current Profile     : Drive Cycle\n');
fprintf('Initial SOC         : %.2f\n', SOC(1));
fprintf('Final SOC           : %.4f\n', SOC(end));
fprintf('Simulation Time     : %.2f s\n', T_end);
fprintf('Time Step           : %.2f s\n', dt);
fprintf('Initial Current     : %.2f A\n', Current(1));
fprintf('Maximum Current     : %.2f A\n', max(Current));
fprintf('Minimum Current     : %.2f A\n', min(Current));

fprintf('====================================================\n');

%% Plot Current Profile
% Plot the time-varying battery current used as the input
% to the dynamic ECM.

figure

plot(t, Current, 'LineWidth', 2)

grid on

xlabel('Time (s)')
ylabel('Current (A)')
title('Current Profile')

%% Plot Terminal Voltage
% Plot the battery terminal-voltage response to the selected
% dynamic current profile.

figure

plot(t, Voltage, 'LineWidth', 2)

grid on

xlabel('Time (s)')
ylabel('Voltage (V)')
title('Terminal Voltage')

%% Plot Open-Circuit Voltage
% Plot the variation of battery OCV resulting from the
% changing SOC during the simulation.

figure

plot(t, OCV, 'LineWidth', 2)

grid on

xlabel('Time (s)')
ylabel('OCV (V)')
title('Open Circuit Voltage')

%% Plot State of Charge
% Plot the SOC trajectory calculated using Coulomb Counting
% during the dynamic current-discharge simulation.

figure

plot(t, SOC, 'LineWidth', 2)

grid on

xlabel('Time (s)')
ylabel('SOC')
title('State of Charge')