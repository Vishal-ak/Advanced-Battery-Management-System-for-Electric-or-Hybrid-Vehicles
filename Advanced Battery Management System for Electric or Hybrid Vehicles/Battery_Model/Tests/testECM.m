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

Current = 2;             % Constant discharge current (A); within configured provisional 5 A limit

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

%% Save Results
% Save each figure as a high-resolution PNG and an editable MATLAB FIG.
% Results are organized by model and test scenario:
% Results/ECM/1RC_ConstantCurrent/

scriptFolder = fileparts(mfilename('fullpath'));
projectRoot = fileparts(scriptFolder);
resultFolder = fullfile(projectRoot, 'Results', 'ECM', '1RC_ConstantCurrent');

if ~exist(resultFolder, 'dir')
    mkdir(resultFolder);
end

scenarioTag = sprintf('ConstantCurrent_%gA_%gs', Current, T);

% Save terminal-voltage figure.
figVoltage = findobj('Type', 'figure');
figVoltage = sort(figVoltage);
% Figures are created in order: voltage, OCV, SOC.
if numel(figVoltage) >= 3
    voltageFig = figVoltage(3);
    ocvFig = figVoltage(2);
    socFig = figVoltage(1);
else
    error('BMS:MissingFigures', 'Expected three ECM result figures were not created.');
end

exportgraphics(voltageFig, fullfile(resultFolder, ...
    ['ECM_1RC_TerminalVoltage_' scenarioTag '.png']), 'Resolution', 300);
savefig(voltageFig, fullfile(resultFolder, ...
    ['ECM_1RC_TerminalVoltage_' scenarioTag '.fig']));

exportgraphics(ocvFig, fullfile(resultFolder, ...
    ['ECM_1RC_OpenCircuitVoltage_' scenarioTag '.png']), 'Resolution', 300);
savefig(ocvFig, fullfile(resultFolder, ...
    ['ECM_1RC_OpenCircuitVoltage_' scenarioTag '.fig']));

exportgraphics(socFig, fullfile(resultFolder, ...
    ['ECM_1RC_StateOfCharge_' scenarioTag '.png']), 'Resolution', 300);
savefig(socFig, fullfile(resultFolder, ...
    ['ECM_1RC_StateOfCharge_' scenarioTag '.fig']));

fprintf('\nResults saved in: %s\\n', resultFolder);
fprintf('Saved 3 figures as PNG (300 dpi) and editable FIG files.\\n');
