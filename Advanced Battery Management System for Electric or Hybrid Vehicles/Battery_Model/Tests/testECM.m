%% Single-cell 1RC ECM demonstration at configured discharge current
clc
clear
close all

battery = initBattery();

dt = 1;                 % Simulation time step (s)
T = 300;                % Total simulation time (s)
time = 0:dt:T;
N = length(time);

SOC = 1.0;
Vrc = 0;
Current = battery.MaxDischargeCurrent; % A; positive means discharge

Voltage = zeros(N,1);
OCV = zeros(N,1);
SOC_History = zeros(N,1);

for k = 1:N
    SOC_History(k) = SOC;
    [Voltage(k),Vrc,OCV(k)] = batteryECM( ...
        SOC,Current,Vrc,dt,battery);
    SOC = coulombCounting(SOC,Current,dt,battery.DesignCapacity);
end

fprintf('\n====================================================\n');
fprintf('              Single-Cell ECM Simulation\n');
fprintf('====================================================\n');
fprintf('Cell model          : %s\n',battery.CellModel);
fprintf('Initial SOC         : %.4f\n',SOC_History(1));
fprintf('Final SOC           : %.4f\n',SOC_History(end));
fprintf('Simulation time     : %.2f s\n',T);
fprintf('Time step           : %.2f s\n',dt);
fprintf('Cell discharge      : %.2f A\n',Current);
fprintf('Configured max      : %.2f A\n',battery.MaxDischargeCurrent);
fprintf('====================================================\n');

figure;
plot(time,Voltage,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('Cell terminal voltage (V)');
title('Single-Cell 1RC ECM Terminal Voltage');

figure;
plot(time,OCV,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('OCV (V)');
title('Single-Cell Open-Circuit Voltage');

figure;
plot(time,SOC_History,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('SOC (fraction)');
title('Single-Cell State of Charge — Coulomb Counting');
