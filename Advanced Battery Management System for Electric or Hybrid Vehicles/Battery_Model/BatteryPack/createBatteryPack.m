function Pack = createBatteryPack(Battery,Ns,Np,verbose)
%CREATEBATTERYPACK Build a series-parallel pack from a cell parameter struct.
% Hardware mass fields are interpreted as total pack-level estimates (kg).
% The volume metric is cell-envelope-only; enclosure geometry is unavailable.

if nargin < 3 || nargin > 4
    error('BMS:InvalidInputCount', ...
        'Usage: createBatteryPack(Battery,Ns,Np,[verbose])');
end
if nargin < 4 || isempty(verbose), verbose = true; end
if ~islogical(verbose) || ~isscalar(verbose)
    error('BMS:InvalidVerboseFlag','verbose must be a logical scalar.');
end
if ~isstruct(Battery) || ~isscalar(Battery)
    error('BMS:InvalidBattery','Battery must be a scalar structure.');
end
if ~isscalar(Ns) || ~isscalar(Np) || ~isfinite(Ns) || ~isfinite(Np) || ...
        Ns < 1 || Np < 1 || fix(Ns) ~= Ns || fix(Np) ~= Np
    error('BMS:InvalidConfiguration','Ns and Np must be positive integers.');
end
required = {'NominalVoltage','MaximumVoltage','CutoffVoltage', ...
    'DesignCapacity','StandardChargeCurrent','MaxDischargeCurrent', ...
    'Mass','SpecificHeat','ThermalResistance','InitialTemperature', ...
    'R0','R1','C1','MinimumSOC','MaximumSOC','InitialSOC','InitialSOH', ...
    'MaxCellTemperature','MinCellTemperature','CellEnergy_Wh', ...
    'Volume_L','Diameter','Height'};
for k = 1:numel(required)
    f = required{k};
    if ~isfield(Battery,f) || ~isnumeric(Battery.(f)) || ...
            ~isscalar(Battery.(f)) || ~isfinite(Battery.(f))
        error('BMS:MissingBatteryParameter', ...
            'Battery.%s must be a finite numeric scalar.',f);
    end
end
if Battery.Mass <= 0 || Battery.DesignCapacity <= 0 || ...
        Battery.NominalVoltage <= 0 || Battery.Volume_L <= 0
    error('BMS:InvalidCellParameter', ...
        'Cell mass, capacity, voltage and volume must be positive.');
end

Pack.Cell = Battery;
Pack.Ns = Ns;
Pack.Np = Np;
Pack.SeriesCells = Ns;
Pack.ParallelCells = Np;
Pack.Configuration = sprintf('%dS%dP',Ns,Np);
Pack.TotalCells = Ns*Np;

Pack.NominalVoltage = Battery.NominalVoltage*Ns;
Pack.MaximumVoltage = Battery.MaximumVoltage*Ns;
Pack.CutoffVoltage = Battery.CutoffVoltage*Ns;
Pack.Capacity = Battery.DesignCapacity*Np;
Pack.CapacityCoulomb = Pack.Capacity*3600;
Pack.StandardChargeCurrent = Battery.StandardChargeCurrent*Np;
Pack.MaxDischargeCurrent = Battery.MaxDischargeCurrent*Np;
Pack.Energy_Wh = Pack.NominalVoltage*Pack.Capacity;
Pack.Energy_kWh = Pack.Energy_Wh/1000;
Pack.TotalCellEnergy_Wh = Battery.CellEnergy_Wh*Pack.TotalCells;

Pack.R0 = Battery.R0*Ns/Np;
Pack.R1 = Battery.R1*Ns/Np;
Pack.C1 = Battery.C1*Np/Ns;
if isfield(Battery,'R2') && isfield(Battery,'C2')
    Pack.R2 = Battery.R2*Ns/Np;
    Pack.C2 = Battery.C2*Np/Ns;
end

Pack.CellMass = Battery.Mass*Pack.TotalCells;
hardwareFields = {'BMSWeight','EnclosureWeight','BusbarWeight','WiringWeight'};
Pack.HardwareMass = 0;
Pack.HardwareMassBreakdown = struct();
for k = 1:numel(hardwareFields)
    f = hardwareFields{k};
    value = 0;
    if isfield(Battery,f), value = Battery.(f); end
    if ~isnumeric(value) || ~isscalar(value) || ~isfinite(value) || value < 0
        error('BMS:InvalidHardwareMass', ...
            'Battery.%s must be a finite nonnegative kg value.',f);
    end
    Pack.HardwareMassBreakdown.(f) = value;
    Pack.HardwareMass = Pack.HardwareMass + value;
end
Pack.Mass = Pack.CellMass + Pack.HardwareMass;
Pack.MassAccounting = "Cell mass + configured pack-level hardware estimates";

Pack.SpecificHeat = Battery.SpecificHeat;
Pack.ThermalResistance = Battery.ThermalResistance/Np;
Pack.InitialTemperature = Battery.InitialTemperature;
Pack.CellDiameter = Battery.Diameter;
Pack.CellHeight = Battery.Height;
Pack.CellVolume_L = Battery.Volume_L;
Pack.CellEnvelopeVolume_L = Battery.Volume_L*Pack.TotalCells;
Pack.Volume_L = Pack.CellEnvelopeVolume_L; % Cell envelope only, not pack enclosure.
Pack.CellEnvelopeEnergyDensity_WhL = Pack.Energy_Wh/Pack.CellEnvelopeVolume_L;
Pack.EnergyDensity_WhL = Pack.CellEnvelopeEnergyDensity_WhL; % Legacy field; not complete-pack density.
Pack.SpecificEnergy_Whkg = Pack.Energy_Wh/Pack.Mass;

Pack.MinimumSOC = Battery.MinimumSOC;
Pack.MaximumSOC = Battery.MaximumSOC;
Pack.InitialSOC = Battery.InitialSOC;
Pack.InitialSOH = Battery.InitialSOH;
Pack.MaxCellTemperature = Battery.MaxCellTemperature;
Pack.MinCellTemperature = Battery.MinCellTemperature;

if verbose
    fprintf('\n=========================================\n');
    fprintf(' BATTERY PACK CREATED\n');
    fprintf('=========================================\n');
    fprintf('Configuration        : %s\n',Pack.Configuration);
    fprintf('Total Cells          : %d\n',Pack.TotalCells);
    fprintf('Nominal Voltage      : %.2f V\n',Pack.NominalVoltage);
    fprintf('Maximum Voltage      : %.2f V\n',Pack.MaximumVoltage);
    fprintf('Cutoff Voltage       : %.2f V\n',Pack.CutoffVoltage);
    fprintf('Capacity             : %.2f Ah\n',Pack.Capacity);
    fprintf('Energy               : %.2f Wh (%.3f kWh)\n',Pack.Energy_Wh,Pack.Energy_kWh);
    fprintf('Cell Mass            : %.3f kg\n',Pack.CellMass);
    fprintf('Hardware Mass Est.   : %.3f kg\n',Pack.HardwareMass);
    fprintf('Total Mass Estimate  : %.3f kg\n',Pack.Mass);
    fprintf('Specific Energy      : %.2f Wh/kg\n',Pack.SpecificEnergy_Whkg);
    fprintf('Cell-envelope density: %.2f Wh/L (not complete-pack density)\n', ...
        Pack.CellEnvelopeEnergyDensity_WhL);
    fprintf('=========================================\n');
end
end