function Battery = initBattery()
%===========================================================
% INITIALIZE PANASONIC NCR18650B BATTERY
%===========================================================

%% File Locations

currentFile = mfilename('fullpath');
parameterFolder = fileparts(currentFile);
projectRoot = fileparts(parameterFolder);

Battery.dataFolder = fullfile( ...
    projectRoot,...
    'Cell_Library',...
    'Panasonic_NCR18650B',...
    'Data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IDENTIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.CellModel = "Panasonic NCR18650B-H00BA";
Battery.Manufacturer = "Panasonic";
Battery.Chemistry = "Lithium-Ion (NCA)";
Battery.CellType = "18650 Cylindrical";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ELECTRICAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.NominalVoltage = 3.7;      % V
Battery.MaximumVoltage = 4.2;      % V
Battery.CutoffVoltage  = 2.5;      % V

Battery.MinimumCapacity = 3.25;    % Ah
Battery.TypicalCapacity = 3.35;    % Ah

% Use this throughout the project
Battery.DesignCapacity = Battery.TypicalCapacity;

Battery.InternalResistance = 0.05; % Ohm

Battery.StandardChargeCurrent = 1.65; % A
Battery.MaxDischargeCurrent = 5.0;    % A

Battery.CapacityCoulomb = ...
    Battery.DesignCapacity * 3600;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PHYSICAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.Mass = 0.0485;         % kg

Battery.Diameter = 18.25;      % mm
Battery.Height = 65.10;        % mm

Battery.CellEnergy_Wh = ...
    Battery.NominalVoltage * Battery.DesignCapacity;

Battery.GravimetricEnergyDensity = 243;   % Wh/kg
Battery.VolumetricEnergyDensity = 676;    % Wh/L

% Cell Volume

radius = Battery.Diameter/2;

Battery.Volume_mm3 = ...
    pi * radius^2 * Battery.Height;

Battery.Volume_L = ...
    Battery.Volume_mm3 / 1e6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% THERMAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.SpecificHeat = 900;      % J/kg-K

Battery.ThermalResistance = 5;   % K/W

Battery.InitialTemperature = 25; % °C

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ECM PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.R0 = 0.045;
Battery.R1 = 0.012;
Battery.C1 = 2400;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SOC / SOH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.InitialSOC = 1.0;

Battery.MinimumSOC = 0.10;
Battery.MaximumSOC = 1.00;

Battery.InitialSOH = 1.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAFETY LIMITS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.MaxCellVoltage = 4.20;
Battery.MinCellVoltage = 2.50;

Battery.MaxCellTemperature = 60;   % °C
Battery.MinCellTemperature = -20;  % °C

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OCV LOOKUP TABLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.OCV = readtable(fullfile( ...
    Battery.dataFolder,...
    'OCV_SOC.csv'));

Battery.SOC_Table = Battery.OCV.SOC;
Battery.OCV_Table = Battery.OCV.OCV;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PACK HARDWARE (FOR ESTIMATION)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Battery.CellCost = 410;   % INR (example, update as needed)

Battery.BMSWeight = 0.25;        % kg
Battery.EnclosureWeight = 0.35;  % kg
Battery.BusbarWeight = 0.15;     % kg
Battery.WiringWeight = 0.10;     % kg

end