%% Single-cell lumped thermal-model demonstration
clear;
clc;
close all;

Battery = initBattery();

dt = 1;
T_end = 300;
time = 0:dt:T_end;

Temperature = zeros(size(time));
Temperature(1) = Battery.InitialTemperature;

% Use the configured cell discharge-current value, not an over-limit
% 20 A single-cell input.
Current = Battery.MaxDischargeCurrent;
AmbientTemperature = Battery.InitialTemperature;

for k = 2:numel(time)
    Heat = calcHeatGeneration(Current,Battery);
    Temperature(k) = updateTemperature( ...
        Temperature(k-1),Heat,AmbientTemperature,dt,Battery);
end

fprintf('Thermal demonstration current: %.2f A per cell\n',Current);
fprintf('Final lumped temperature: %.3f degC\n',Temperature(end));

figure;
plot(time,Temperature,'LineWidth',2);
grid on;
xlabel('Time (s)');
ylabel('Cell temperature (degC)');
title('Single-Cell Lumped Thermal Response');
