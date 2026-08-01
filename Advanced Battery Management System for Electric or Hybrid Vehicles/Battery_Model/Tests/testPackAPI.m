clc
clear
close all

%% Initialize Battery

Battery = initBattery();

%% Create Pack

Pack = createBatteryPack(Battery,13,6);

%% Cell Operating Conditions

CellVoltage = Battery.NominalVoltage;          % V
CellCurrent = Battery.MaxDischargeCurrent;     % A

%% Pack API

Vpack = packVoltage(CellVoltage,Pack);

Ipack = packCurrent(CellCurrent,Pack);

Power = packPower(Vpack,Ipack);

[EWh,EkWh] = packEnergy(Vpack,Pack.Capacity);

%% Display

fprintf("\n");
fprintf("=========================================\n");
fprintf(" BATTERY PACK API TEST\n");
fprintf("=========================================\n");

fprintf("Configuration        : %s\n",Pack.Configuration);
fprintf("Total Cells          : %d\n",Pack.TotalCells);

fprintf("\n");

fprintf("Cell Voltage         : %.2f V\n",CellVoltage);
fprintf("Pack Voltage         : %.2f V\n",Vpack);

fprintf("\n");

fprintf("Cell Current         : %.2f A\n",CellCurrent);
fprintf("Pack Current         : %.2f A\n",Ipack);

fprintf("\n");

fprintf("Pack Power           : %.2f W\n",Power);

fprintf("Pack Energy          : %.2f Wh\n",EWh);
fprintf("Pack Energy          : %.2f kWh\n",EkWh);
fprintf('Energy Density       : %.2f Wh/L\n',Pack.EnergyDensity_WhL);

fprintf("\n");

fprintf("Pack Capacity        : %.2f Ah\n",Pack.Capacity);
fprintf("Max Current          : %.2f A\n",Pack.MaxDischargeCurrent);

fprintf("Pack Mass            : %.2f kg\n",Pack.Mass);

fprintf("Specific Energy      : %.2f Wh/kg\n",...
    Pack.SpecificEnergy_Whkg);

fprintf("=========================================\n");