clc
clear
close all

%% Initialize Battery

battery = initBattery();

%% Simulation Parameters

dt = 1;

T = 300;

time = 0:dt:T;

N = length(time);

%% Initial Conditions

SOC = 1;

Vrc = 0;

Current = 8;

%% Allocate Memory

Voltage = zeros(N,1);

OCV = zeros(N,1);

SOC_History = zeros(N,1);

%% Simulation Loop

for k = 1:N

    SOC_History(k) = SOC;

    [Voltage(k),Vrc,OCV(k)] = batteryECM( ...
        SOC,...
        Current,...
        Vrc,...
        dt,...
        battery);

    SOC = coulombCounting( ...
        SOC,...
        Current,...
        dt,...
        battery.NominalCapacity);

end

%% Plot Terminal Voltage

figure

plot(time,Voltage,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('Voltage (V)')

title('Terminal Voltage')

%% Plot OCV

figure

plot(time,OCV,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('OCV (V)')

title('Open Circuit Voltage')

%% Plot SOC

figure

plot(time,SOC_History,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('SOC')

title('State of Charge')