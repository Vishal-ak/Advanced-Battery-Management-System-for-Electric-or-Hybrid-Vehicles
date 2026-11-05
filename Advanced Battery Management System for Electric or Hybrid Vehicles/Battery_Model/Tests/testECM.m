%% ==========================================================
% testECMSimulation.m
%
% Project:
% Modeling and Simulation of a Hybrid Electric Vehicle Powertrain
%
% Tests the 1RC Equivalent Circuit Model (ECM)
% using a constant current input.
%
% The script evaluates terminal voltage, OCV, and SOC
% during the battery simulation.
%
% Author: Vishal Mishra
%% ==========================================================

clc
clear
close all

%% Initialize Battery
% Load the reference battery-cell parameters and model data
% required for the ECM and SOC calculations.

battery = initBattery();

%% Simulation Parameters
% Define the simulation time step and total simulation duration.
% The time vector is used to record the battery response.

dt = 1;                  % Simulation time step (s)
T = 300;                 % Total simulation time (s)

time = 0:dt:T;
N = length(time);

%% Initial Conditions
% Set the initial state of charge and polarization voltage
% for the battery ECM simulation.

SOC = 1;                 % Initial SOC
Vrc = 0;                 % Initial RC polarization voltage (V)

% Apply a constant discharge current throughout the simulation.

Current = 8;             % Constant discharge current (A)

%% Allocate Memory
% Pre-allocate arrays for storing terminal voltage, open-circuit
% voltage, and SOC values at each simulation time step.

Voltage = zeros(N,1);
OCV = zeros(N,1);
SOC_History = zeros(N,1);

%% Battery ECM Simulation
% At each time step, calculate the battery terminal voltage and
% OCV using the 1RC ECM, then update SOC using Coulomb Counting.

for k = 1:N

    SOC_History(k) = SOC;

    [Voltage(k), Vrc, OCV(k)] = batteryECM( ...
        SOC, ...
        Current, ...
        Vrc, ...
        dt, ...
        battery);

    SOC = coulombCounting( ...
        SOC, ...
        Current, ...
        dt, ...
        battery.DesignCapacity);

end

%% Display Simulation Information
% Display the main simulation settings and the initial and
% final SOC values obtained from the simulation.

fprintf('\n');
fprintf('====================================================\n');
fprintf('              Battery ECM Simulation\n');
fprintf('====================================================\n');
fprintf('Current Profile     : Constant Current\n');
fprintf('Initial SOC         : %.2f\n', SOC_History(1));
fprintf('Final SOC           : %.4f\n', SOC_History(end));
fprintf('Simulation Time     : %.2f s\n', T);
fprintf('Time Step           : %.2f s\n', dt);
fprintf('Current             : %.2f A\n', Current);
fprintf('====================================================\n');

%% Plot Terminal Voltage
% Plot the battery terminal-voltage response during the
% constant-current discharge simulation.

figure

plot(time, Voltage, 'LineWidth', 2)

grid on

xlabel('Time (s)')
ylabel('Voltage (V)')
title('Terminal Voltage')

%% Plot Open-Circuit Voltage
% Plot the variation of OCV resulting from the change in
% battery SOC during the simulation.

figure

plot(time, OCV, 'LineWidth', 2)

grid on

xlabel('Time (s)')
ylabel('OCV (V)')
title('Open Circuit Voltage')

%% Plot State of Charge
% Plot the SOC trajectory calculated using Coulomb Counting
% during the constant-current discharge.

figure

plot(time, SOC_History, 'LineWidth', 2)

grid on

xlabel('Time (s)')
ylabel('SOC')
title('State of Charge')