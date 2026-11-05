clear;
clc;
close all;

%% Initialize Battery Model
% Load the reference battery-cell parameters, including
% electrical and thermal characteristics.

Battery = initBattery();

%% Simulation Settings
% Define the simulation time step and total simulation duration.

dt = 1;
T_end = 300;

time = 0:dt:T_end;

%% Initialize Temperature
% Create a temperature history array and set the initial
% cell temperature using the battery model parameters.

Temperature = zeros(size(time));

Temperature(1) = Battery.InitialTemperature;

%% Define Constant Current
% Apply a constant discharge current to evaluate the
% temperature rise of the battery during operation.

Current = 20;

%% Thermal Simulation
% Calculate heat generation at each time step and update
% the battery temperature using the thermal model.

for k = 2:length(time)

    Heat = calcHeatGeneration(Current, Battery);

    Temperature(k) = updateTemperature( ...
        Temperature(k-1), ...
        Heat, ...
        25, ...
        dt, ...
        Battery);

end

%% Plot Battery Temperature
% Plot the variation of battery temperature with time
% during the constant-current thermal simulation.

figure

plot(time, Temperature, 'LineWidth', 2)

grid on

xlabel('Time (s)')
ylabel('Temperature (°C)')
title('Battery Temperature Rise')