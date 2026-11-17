function Battery = initBattery()
%INITBATTERY Load project model parameters for the Panasonic NCR18650B.
% Values are project inputs. Confirm against the exact manufacturer
% datasheet revision and traceable cell characterization before deployment.

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

%% Electrical parameters (project model configuration)
Battery.NominalVoltage = 3.70;       % V
Battery.MaximumVoltage = 4.20;       % V
Battery.CutoffVoltage = 2.50;        % V
Battery.MinimumCapacity = 3.25;      % Ah
Battery.TypicalCapacity = 3.35;      % Ah
Battery.DesignCapacity = Battery.TypicalCapacity;

% Retain the legacy resistance field for compatibility, but distinguish it
% explicitly from the ohmic resistance currently used by the ECM.
Battery.InternalResistance = 0.050;  % Ohm; legacy/general model field
Battery.R0 = 0.045; % Ohm; preliminary ECM parameter, requires cell characterization                  % Ohm; ECM ohmic resistance
Battery.StandardChargeCurrent = 1.625; % A; manufacturer standard charge current; project assumption
Battery.MaxDischargeCurrent = 5.0;    % A; project assumption
Battery.CapacityCoulomb = Battery.DesignCapacity*3600;

%% Physical parameters
Battery.Mass = 0.0485;              % kg
Battery.Diameter = 18.25;           % mm
Battery.Height = 65.10;             % mm
Battery.CellEnergy_Wh = Battery.NominalVoltage*Battery.DesignCapacity;
Battery.GravimetricEnergyDensity = 243; % Wh/kg; project reference
Battery.VolumetricEnergyDensity = 676;  % Wh/L; project reference

radius_mm = Battery.Diameter/2;
Battery.Volume_mm3 = pi*radius_mm^2*Battery.Height;
Battery.Volume_L = Battery.Volume_mm3/1e6;

%% Lumped thermal parameters (project assumptions)
Battery.SpecificHeat = 900;             % J/(kg K)
Battery.ThermalResistance = 5;          % K/W
Battery.InitialTemperature = 25;        % degC

%% ECM parameters
Battery.R1 = 0.012; % Ohm; preliminary ECM parameter   % Ohm; preliminary polarization parameter
Battery.C1 = 2400; % F; preliminary ECM parameter    % F; preliminary polarization parameter
Battery.R2 = 0.015; % Ohm; preliminary 2RC parameter   % Ohm; preliminary 2RC parameter
Battery.C2 = 8000; % F; preliminary 2RC parameter    % F; preliminary 2RC parameter

%% SOC/SOH initial conditions and configured limits
Battery.InitialSOC = 1.0;
Battery.MinimumSOC = 0.10;
Battery.MaximumSOC = 1.00;
Battery.InitialSOH = 1.0;

%% Configured cell operating limits (verify for application)
Battery.MaxCellVoltage = Battery.MaximumVoltage;
Battery.MinCellVoltage = Battery.CutoffVoltage;
Battery.MaxCellTemperature = 60;   % degC; model limit
Battery.MinCellTemperature = -20;  % degC; model limit

%% Load and validate OCV-SOC lookup data
ocvFile = fullfile(Battery.dataFolder,'OCV_SOC.csv');
if ~isfile(ocvFile)
    error('BMS:MissingOCVData','Required OCV-SOC data file not found: %s',ocvFile);
end
Battery.OCV = readtable(ocvFile);
requiredColumns = {'SOC','OCV'};
if ~all(ismember(requiredColumns,Battery.OCV.Properties.VariableNames))
    error('BMS:InvalidOCVTable', ...
        'OCV_SOC.csv must contain columns named SOC and OCV.');
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
Battery.CellCost = 410;             % INR; illustrative cell-only cost
Battery.BMSWeight = 0.25;           % kg
Battery.EnclosureWeight = 0.35;     % kg
Battery.BusbarWeight = 0.15;        % kg
Battery.WiringWeight = 0.10;        % kg
end
