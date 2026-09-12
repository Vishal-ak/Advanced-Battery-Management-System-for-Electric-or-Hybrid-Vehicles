clc;
clear;
close all;

%% Battery Parameters
% Define the battery capacity, initial state of charge (SOC),
% and sampling time used for Coulomb Counting.

Capacity = 3.35;       % Battery capacity (Ah)
SOC0 = 1.0;             % Initial SOC
dt = 1;                 % Sampling time (s)

%% Simulation Time
% Define the total simulation duration and time vector.
% The simulation represents a 1-hour discharge period.

T = 3600;               % Simulation time (s)
t = 0:dt:T;

%% Current Profiles
% Positive current represents battery discharge.
% Three different discharge profiles are generated to compare
% their effect on the battery state of charge.

% 1. Constant-current discharge
% Battery is discharged continuously at a constant current of 2 A.

I_constant = 2 * ones(size(t));

% 2. Step-current discharge
% The discharge current is increased in three stages:
% 1 A for the first 20 minutes,
% 3 A for the next 20 minutes, and
% 5 A for the final 20 minutes.

I_step = zeros(size(t));
I_step(t < 1200) = 1;
I_step(t >= 1200 & t < 2400) = 3;
I_step(t >= 2400) = 5;

% 3. Pulse-current discharge
% The battery operates mainly at 2 A, with periodic
% 5 A current pulses of 100 seconds every 400 seconds.

I_pulse = 2 * ones(size(t));
I_pulse(mod(t,400) < 100) = 5;

%% Initialize SOC History
% Allocate arrays to store the SOC variation for each
% current-discharge profile.

SOC_constant = zeros(size(t));
SOC_step = zeros(size(t));
SOC_pulse = zeros(size(t));

% Set the initial SOC for all three simulations.

SOC_constant(1) = SOC0;
SOC_step(1) = SOC0;
SOC_pulse(1) = SOC0;

%% Calculate SOC Using Coulomb Counting
% Calculate the SOC at every time step using the
% Coulomb Counting method for each current profile.

for k = 2:length(t)

    SOC_constant(k) = coulombCounting( ...
        SOC_constant(k-1), ...
        I_constant(k), ...
        dt, ...
        Capacity);

    SOC_step(k) = coulombCounting( ...
        SOC_step(k-1), ...
        I_step(k), ...
        dt, ...
        Capacity);

    SOC_pulse(k) = coulombCounting( ...
        SOC_pulse(k-1), ...
        I_pulse(k), ...
        dt, ...
        Capacity);

end

%% Display SOC Results
% Display the initial SOC and final SOC obtained for
% each discharge-current profile.

fprintf('\n========================================\n');
fprintf('        SOC DISCHARGE TEST\n');
fprintf('========================================\n');

fprintf('Initial SOC              : %.4f\n', SOC0);
fprintf('Constant Current Final   : %.4f\n', SOC_constant(end));
fprintf('Step Current Final       : %.4f\n', SOC_step(end));
fprintf('Pulse Current Final      : %.4f\n', SOC_pulse(end));

fprintf('========================================\n');

%% Plot SOC Variation
% Compare the SOC variation with time for constant,
% step, and pulse current discharge conditions.

figure;

plot(t/60, SOC_constant, 'LineWidth', 2);
hold on;

plot(t/60, SOC_step, 'LineWidth', 2);
plot(t/60, SOC_pulse, 'LineWidth', 2);

xlabel('Time (min)');
ylabel('State of Charge (SOC)');
title('SOC Variation During Different Current Discharge Profiles');

legend('Constant Current', ...
       'Step Current', ...
       'Pulse Current', ...
       'Location', 'best');

grid on;
ylim([0 1.05]);