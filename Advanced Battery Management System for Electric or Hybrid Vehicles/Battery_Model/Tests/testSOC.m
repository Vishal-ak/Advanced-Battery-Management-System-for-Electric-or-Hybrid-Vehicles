clc;
clear;

SOC = 1.0;      % Initial SOC
I = 5;          % Current (A)
dt = 1;         % Sampling time (s)
Capacity = 3.35;

SOC_new = coulombCounting(SOC, I, dt, Capacity);

fprintf('Initial SOC : %.4f\n', SOC);
fprintf('Updated SOC : %.4f\n', SOC_new);