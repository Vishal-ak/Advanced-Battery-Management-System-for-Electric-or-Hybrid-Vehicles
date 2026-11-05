%% ==========================================================
% Battery Parameters
% Panasonic NCR18650B
% ===========================================================

Battery = initBattery();

%% Cell Parameters

Capacity = Battery.NominalCapacity;      % Ah
Q = Capacity * 3600;                     % Coulombs

NominalVoltage = Battery.NominalVoltage;
MaximumVoltage = Battery.MaximumVoltage;
CutoffVoltage  = Battery.CutoffVoltage;

%% ECM Parameters

R0 = Battery.InternalResistance;

% Temporary values
R1 = 0.0015;
C1 = 3.5e4;

%% Battery Pack

Ns = 80;
Np = 1;

PackCapacity = Capacity * Np;       % Ah
Q_batt = Q * Np;                    % Coulombs

V_nominal = Ns * NominalVoltage;
V_max     = Ns * MaximumVoltage;
V_cutoff  = Ns * CutoffVoltage;

Energy_nominal = V_nominal * PackCapacity;   % Wh

%% Display

fprintf('\n');
fprintf('========================================\n');
fprintf(' Panasonic NCR18650B Battery Pack\n');
fprintf('========================================\n');

fprintf('Cell Capacity        : %.2f Ah\n', Capacity);
fprintf('Pack Capacity        : %.2f Ah\n', PackCapacity);
fprintf('Nominal Voltage      : %.2f V\n', V_nominal);
fprintf('Maximum Voltage      : %.2f V\n', V_max);
fprintf('Cutoff Voltage       : %.2f V\n', V_cutoff);
fprintf('Pack Energy          : %.2f Wh\n', Energy_nominal);
fprintf('Series Cells (Ns)    : %d\n', Ns);
fprintf('Parallel Cells (Np)  : %d\n', Np);

fprintf('========================================\n');