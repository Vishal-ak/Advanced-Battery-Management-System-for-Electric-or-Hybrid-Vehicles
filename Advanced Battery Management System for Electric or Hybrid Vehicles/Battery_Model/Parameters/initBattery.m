function Battery = initBattery()
%INITBATTERY Load project model parameters for the Panasonic NCR18650B.
% Manufacturer ratings and project modelling assumptions are distinguished.
% Confirm exact datasheet revision and cell characterization before hardware use.

currentFile = mfilename('fullpath');
parameterFolder = fileparts(currentFile);
projectRoot = fileparts(parameterFolder);
Battery.dataFolder = fullfile(projectRoot,'Cell_Library', ...
    'Panasonic_NCR18650B','Data');

%% Cell identity
Battery.CellModel = "Panasonic NCR18650B";
Battery.Manufacturer = "Panasonic";
Battery.Chemistry = "Lithium-Ion (cathode chemistry not specified in referenced datasheet)";
Battery.CellType = "18650 Cylindrical";

%% Electrical parameters
Battery.NominalVoltage = 3.60;       % V; manufacturer nominal voltage
Battery.MaximumVoltage = 4.20;       % V; manufacturer charging voltage
Battery.CutoffVoltage = 2.50;        % V; datasheet discharge cutoff condition
Battery.MinimumCapacity = 3.25;      % Ah; minimum capacity under datasheet test conditions
Battery.TypicalCapacity = 3.35;      % Ah; typical capacity under datasheet test conditions
Battery.DesignCapacity = Battery.TypicalCapacity;

% Separate legacy/general resistance from the ECM parameter. Neither is a
% universal fixed cell resistance; characterize versus SOC and temperature.
Battery.InternalResistance = 0.050;  % Ohm; legacy/project parameter
Battery.R0 = 0.045;                  % Ohm; preliminary ECM parameter
Battery.StandardChargeCurrent = 1.625; % A; manufacturer standard charge current
Battery.MaxDischargeCurrent = 5.0;    % A; conservative project limit, not a datasheet maximum rating
Battery.CapacityCoulomb = Battery.DesignCapacity*3600;

%% Physical parameters
Battery.Mass = 0.0485;               % kg; configured maximum-mass value (datasheet revision dependent)
Battery.Diameter = 18.25;            % mm; bare-cell geometric assumption
Battery.Height = 65.10;              % mm; bare-cell geometric assumption
Battery.CellEnergy_Wh = Battery.NominalVoltage*Battery.DesignCapacity;
Battery.GravimetricEnergyDensity = 243; % Wh/kg; datasheet reference value
Battery.VolumetricEnergyDensity = 676;  % Wh/L; datasheet bare-cell reference value
radius_mm = Battery.Diameter/2;
Battery.Volume_mm3 = pi*radius_mm^2*Battery.Height;
Battery.Volume_L = Battery.Volume_mm3/1e6;

%% Lumped thermal parameters (project assumptions; require validation)
Battery.SpecificHeat = 900;          % J/(kg K)
Battery.ThermalResistance = 5;       % K/W
Battery.InitialTemperature = 25;     % degC

%% ECM parameters (preliminary; identify using cell tests)
Battery.R1 = 0.012;                  % Ohm
Battery.C1 = 2400;                   % F
Battery.R2 = 0.015;                  % Ohm
Battery.C2 = 8000;                   % F

%% SOC and SOH initial conditions
Battery.InitialSOC = 1.0;
Battery.MinimumSOC = 0.10;
Battery.MaximumSOC = 1.00;
Battery.InitialSOH = 1.0;

%% Configured temperature limits
Battery.MinCellTemperature = -20;   % degC; discharge ambient limit
Battery.MaxCellTemperature = 60;    % degC; discharge ambient limit
Battery.MinChargeTemperature = 0;   % degC; charge temperature lower limit
Battery.MaxChargeTemperature = 45;  % degC; charge temperature upper limit
Battery.MaxCellVoltage = Battery.MaximumVoltage;
Battery.MinCellVoltage = Battery.CutoffVoltage;

%% Load and validate OCV-SOC lookup data
ocvFile = fullfile(Battery.dataFolder,'OCV_SOC.csv');
if ~isfile(ocvFile)
    error('BMS:MissingOCVData','Required OCV-SOC data file not found: %s',ocvFile);
end
Battery.OCV = readtable(ocvFile);
requiredColumns = {'SOC','OCV'};
if ~all(ismember(requiredColumns,Battery.OCV.Properties.VariableNames))
    error('BMS:InvalidOCVTable','OCV_SOC.csv must contain columns named SOC and OCV.');
end
Battery.SOC_Table = Battery.OCV.SOC;
Battery.OCV_Table = Battery.OCV.OCV;
soc = Battery.SOC_Table;
ocv = Battery.OCV_Table;
if ~isnumeric(soc) || ~isnumeric(ocv) || ~isvector(soc) || ...
        ~isvector(ocv) || numel(soc) < 2 || numel(soc) ~= numel(ocv) || ...
        any(~isfinite(soc(:))) || any(~isfinite(ocv(:))) || ...
        any(diff(soc(:)) <= 0) || min(soc) < 0 || max(soc) > 1
    error('BMS:InvalidOCVTable', ...
        'OCV lookup must contain finite numeric data with strictly increasing SOC in [0,1].');
end

%% Pack hardware estimation assumptions (kg; pack-level allowances)
Battery.CellCost = 410;              % INR; illustrative cell-only cost
Battery.BMSWeight = 0.25;            % kg
Battery.EnclosureWeight = 0.35;      % kg
Battery.BusbarWeight = 0.15;         % kg
Battery.WiringWeight = 0.10;         % kg
end
