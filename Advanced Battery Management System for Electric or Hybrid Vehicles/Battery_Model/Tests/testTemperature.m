clear;
clc;
close all;

%% Load Battery

Battery = initBattery();

%% Simulation Settings

dt = 1;
T_end = 300;

time = 0:dt:T_end;

%% Initial Temperature

Temperature = zeros(size(time));

Temperature(1) = Battery.InitialTemperature;

%% Constant Current

Current = 20;

%% Simulation

for k = 2:length(time)

    Heat = calcHeatGeneration(Current, Battery);

    Temperature(k) = updateTemperature( ...
        Temperature(k-1), ...
        Heat, ...
        25, ...
        dt, ...
        Battery);

end

%% Plot

figure

plot(time, Temperature, 'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('Temperature (°C)')

title('Battery Temperature Rise')