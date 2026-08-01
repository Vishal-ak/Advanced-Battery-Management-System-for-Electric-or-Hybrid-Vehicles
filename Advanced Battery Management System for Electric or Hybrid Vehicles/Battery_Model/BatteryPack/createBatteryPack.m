function Pack = createBatteryPack(Battery,Ns,Np)
%===========================================================
% CREATE BATTERY PACK
%
% Creates a battery pack from a single cell model.
%
% Inputs
% -------
% Battery : Cell parameter structure
% Ns      : Number of series cells
% Np      : Number of parallel strings
%
% Output
% -------
% Pack    : Battery pack structure
%===========================================================

%% Input Validation

if nargin ~= 3
    error('Usage: createBatteryPack(Battery,Ns,Np)');
end

if Ns < 1 || Np < 1
    error('Ns and Np must be greater than zero.');
end

if floor(Ns) ~= Ns || floor(Np) ~= Np
    error('Ns and Np must be integers.');
end

%% Store Cell

Pack.Cell = Battery;

%% Configuration

Pack.Ns = Ns;
Pack.Np = Np;

Pack.Configuration = sprintf('%dS%dP',Ns,Np);

%% Cell Count

Pack.TotalCells = Ns * Np;

%% Voltage

Pack.NominalVoltage = Battery.NominalVoltage * Ns;

Pack.MaximumVoltage = Battery.MaximumVoltage * Ns;

Pack.CutoffVoltage = Battery.CutoffVoltage * Ns;

%% Capacity

Pack.Capacity = Battery.DesignCapacity * Np;

Pack.CapacityCoulomb = Pack.Capacity * 3600;

%% Current Ratings

Pack.StandardChargeCurrent = ...
    Battery.StandardChargeCurrent * Np;

Pack.MaxDischargeCurrent = ...
    Battery.MaxDischargeCurrent * Np;

%% Energy

Pack.CellEnergy_Wh = Battery.CellEnergy_Wh;

Pack.Energy_Wh = ...
    Pack.NominalVoltage * Pack.Capacity;

Pack.Energy_kWh = ...
    Pack.Energy_Wh / 1000;

Pack.TotalCellEnergy_Wh = ...
    Battery.CellEnergy_Wh * Pack.TotalCells;

%% ECM Parameters

Pack.R0 = Battery.R0 * Ns / Np;

Pack.R1 = Battery.R1 * Ns / Np;

Pack.C1 = Battery.C1 * Np / Ns;

%% Thermal

Pack.Mass = ...
    Battery.Mass * Pack.TotalCells;

Pack.SpecificHeat = ...
    Battery.SpecificHeat;

Pack.ThermalResistance = ...
    Battery.ThermalResistance / Np;

Pack.InitialTemperature = ...
    Battery.InitialTemperature;

%% Physical

Pack.CellDiameter = Battery.Diameter;

Pack.CellHeight = Battery.Height;

Pack.CellVolume_L = Battery.Volume_L;

Pack.Volume_L = ...
    Battery.Volume_L * Pack.TotalCells;

%% Performance

Pack.SpecificEnergy_Whkg = ...
    Pack.Energy_Wh / Pack.Mass;

Pack.EnergyDensity_WhL = ...
    Pack.Energy_Wh / Pack.Volume_L;

%% Safety Limits

Pack.MinimumSOC = Battery.MinimumSOC;

Pack.MaximumSOC = Battery.MaximumSOC;

Pack.InitialSOC = Battery.InitialSOC;

Pack.InitialSOH = Battery.InitialSOH;

Pack.MaxCellTemperature = ...
    Battery.MaxCellTemperature;

Pack.MinCellTemperature = ...
    Battery.MinCellTemperature;

%% Display

fprintf('\n');
fprintf('=========================================\n');
fprintf(' BATTERY PACK CREATED\n');
fprintf('=========================================\n');

fprintf('Configuration        : %s\n',Pack.Configuration);

fprintf('Series Cells         : %d\n',Pack.Ns);

fprintf('Parallel Cells       : %d\n',Pack.Np);

fprintf('Total Cells          : %d\n',Pack.TotalCells);

fprintf('\n');

fprintf('Nominal Voltage      : %.2f V\n',Pack.NominalVoltage);

fprintf('Maximum Voltage      : %.2f V\n',Pack.MaximumVoltage);

fprintf('Cutoff Voltage       : %.2f V\n',Pack.CutoffVoltage);

fprintf('\n');

fprintf('Capacity             : %.2f Ah\n',Pack.Capacity);

fprintf('Energy               : %.2f Wh\n',Pack.Energy_Wh);

fprintf('Energy               : %.2f kWh\n',Pack.Energy_kWh);

fprintf('Energy Density       : %.2f Wh/L\n',Pack.EnergyDensity_WhL);

fprintf('\n');

fprintf('Max Discharge Current: %.2f A\n',Pack.MaxDischargeCurrent);

fprintf('Charge Current       : %.2f A\n',Pack.StandardChargeCurrent);

fprintf('\n');

fprintf('Pack Mass            : %.2f kg\n',Pack.Mass);

fprintf('Specific Energy      : %.2f Wh/kg\n',Pack.SpecificEnergy_Whkg);


fprintf('=========================================\n');

end