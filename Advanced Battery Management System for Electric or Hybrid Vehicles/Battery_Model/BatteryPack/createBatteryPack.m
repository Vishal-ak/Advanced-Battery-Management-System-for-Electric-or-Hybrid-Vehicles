function Pack = createBatteryPack(Battery,Ns,Np,verbose)
%CREATEBATTERYPACK Construct a series-parallel battery pack.
% Hardware mass fields in Battery are pack-level kg estimates.
% Volume is cell-envelope-only, not complete enclosure volume.

if nargin < 3 || nargin > 4
    error('BMS:InvalidInputCount','Usage: createBatteryPack(Battery,Ns,Np,[verbose])');
end
if nargin < 4 || isempty(verbose), verbose = true; end
if ~isstruct(Battery) || ~isscalar(Battery)
    error('BMS:InvalidBattery','Battery must be a scalar structure.');
end
if ~isnumeric(Ns) || ~isnumeric(Np) || ~isscalar(Ns) || ~isscalar(Np) || ...
        ~isfinite(Ns) || ~isfinite(Np) || Ns < 1 || Np < 1 || ...
        fix(Ns) ~= Ns || fix(Np) ~= Np
    error('BMS:InvalidConfiguration','Ns and Np must be positive integers.');
end
required = {'NominalVoltage','MaximumVoltage','CutoffVoltage','DesignCapacity', ...
    'StandardChargeCurrent','MaxDischargeCurrent','Mass','SpecificHeat', ...
    'ThermalResistance','InitialTemperature','R0','R1','C1','CellEnergy_Wh', ...
    'Volume_L','Diameter','Height','MinimumSOC','MaximumSOC','InitialSOC', ...
    'InitialSOH','MaxCellTemperature','MinCellTemperature', ...
    'MinChargeTemperature','MaxChargeTemperature','LowTempChargeTemperatureThreshold', ...
    'LowTempChargeCurrent'};
for k = 1:numel(required)
    f = required{k};
    if ~isfield(Battery,f) || ~isnumeric(Battery.(f)) || ...
            ~isscalar(Battery.(f)) || ~isfinite(Battery.(f))
        error('BMS:MissingBatteryParameter', ...
            'Battery.%s must be a finite numeric scalar.',f);
    end
end
positive = {'NominalVoltage','DesignCapacity','Mass','Volume_L','R0','R1','C1'};
for k = 1:numel(positive)
    f = positive{k};
    if Battery.(f) <= 0
        error('BMS:InvalidCellParameter','Battery.%s must be positive.',f);
    end
end
if Battery.CutoffVoltage <= 0 || ...
        Battery.CutoffVoltage >= Battery.NominalVoltage || ...
        Battery.NominalVoltage >= Battery.MaximumVoltage
    error('BMS:InvalidVoltageLimits', ...
        'Expected 0 < cutoff voltage < nominal voltage < maximum voltage.');
end
if Battery.StandardChargeCurrent <= 0 || Battery.MaxDischargeCurrent <= 0
    error('BMS:InvalidCurrentLimit','Charge/discharge current limits must be positive.');
end
if Battery.MinChargeTemperature >= Battery.MaxChargeTemperature || ...
        Battery.MinCellTemperature >= Battery.MaxCellTemperature
    error('BMS:InvalidTemperatureLimits','Temperature bounds must be ordered.');
end

Pack.Cell = Battery;
Pack.Ns = Ns; Pack.Np = Np;
Pack.SeriesCells = Ns; Pack.ParallelCells = Np;
Pack.Configuration = sprintf('%dS%dP',Ns,Np);
Pack.TotalCells = Ns*Np;
Pack.NominalVoltage = Battery.NominalVoltage*Ns;
Pack.MaximumVoltage = Battery.MaximumVoltage*Ns;
Pack.CutoffVoltage = Battery.CutoffVoltage*Ns;
Pack.Capacity = Battery.DesignCapacity*Np;
Pack.CapacityCoulomb = Pack.Capacity*3600;
Pack.StandardChargeCurrent = Battery.StandardChargeCurrent*Np;
Pack.MaxDischargeCurrent = Battery.MaxDischargeCurrent*Np;
Pack.CellEnergy_Wh = Battery.CellEnergy_Wh;
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
hardware = {'BMSWeight','EnclosureWeight','BusbarWeight','WiringWeight'};
Pack.HardwareMassBreakdown = struct();
Pack.HardwareMass = 0;
for k = 1:numel(hardware)
    f = hardware{k};
    value = 0;
    if isfield(Battery,f), value = Battery.(f); end
    if ~isnumeric(value) || ~isscalar(value) || ~isfinite(value) || value < 0
        error('BMS:InvalidHardwareMass','Battery.%s must be a nonnegative kg scalar.',f);
    end
    Pack.HardwareMassBreakdown.(f) = value;
    Pack.HardwareMass = Pack.HardwareMass+value;
end
Pack.Mass = Pack.CellMass+Pack.HardwareMass;
Pack.MassAccounting = "Cell mass plus configured pack-level hardware estimates";

Pack.SpecificHeat = Battery.SpecificHeat;
Pack.ThermalResistance = Battery.ThermalResistance/Np;
Pack.InitialTemperature = Battery.InitialTemperature;
Pack.CellDiameter = Battery.Diameter;
Pack.CellHeight = Battery.Height;
Pack.CellVolume_L = Battery.Volume_L;
Pack.CellEnvelopeVolume_L = Battery.Volume_L*Pack.TotalCells;
Pack.Volume_L = Pack.CellEnvelopeVolume_L; % legacy field; cell envelope only
Pack.VolumeBasis = "Cell envelope only; enclosure and hardware volume excluded";
Pack.SpecificEnergy_Whkg = Pack.Energy_Wh/Pack.Mass;
Pack.EnergyDensity_WhL = Pack.Energy_Wh/Pack.CellEnvelopeVolume_L;
Pack.EnergyDensityBasis = "Cell-envelope estimate; not complete-pack density";

Pack.MinimumSOC = Battery.MinimumSOC;
Pack.MaximumSOC = Battery.MaximumSOC;
Pack.InitialSOC = Battery.InitialSOC;
Pack.InitialSOH = Battery.InitialSOH;
Pack.MaxCellTemperature = Battery.MaxCellTemperature;
Pack.MinCellTemperature = Battery.MinCellTemperature;
Pack.MinChargeTemperature = Battery.MinChargeTemperature;
Pack.MaxChargeTemperature = Battery.MaxChargeTemperature;
Pack.LowTempChargeTemperatureThreshold = Battery.LowTempChargeTemperatureThreshold;
Pack.LowTempChargeCurrent = Battery.LowTempChargeCurrent;

if verbose
    fprintf('\n=== BATTERY PACK CREATED ===\n');
    fprintf('Configuration        : %s (%d cells)\n',Pack.Configuration,Pack.TotalCells);
    fprintf('Nominal voltage      : %.2f V\n',Pack.NominalVoltage);
    fprintf('Voltage range        : %.2f to %.2f V\n',Pack.CutoffVoltage,Pack.MaximumVoltage);
    fprintf('Capacity / energy    : %.2f Ah / %.2f Wh\n',Pack.Capacity,Pack.Energy_Wh);
    fprintf('Pack charge current  : %.2f A (standard limit)\n',Pack.StandardChargeCurrent);
    fprintf('Pack discharge limit : %.2f A (project limit)\n',Pack.MaxDischargeCurrent);
    fprintf('Cell mass            : %.3f kg\n',Pack.CellMass);
    fprintf('Hardware mass est.   : %.3f kg\n',Pack.HardwareMass);
    fprintf('Total mass estimate  : %.3f kg\n',Pack.Mass);
    fprintf('Specific energy      : %.2f Wh/kg\n',Pack.SpecificEnergy_Whkg);
    fprintf('Cell-envelope density: %.2f Wh/L (not complete-pack density)\n',Pack.EnergyDensity_WhL);
end
end
