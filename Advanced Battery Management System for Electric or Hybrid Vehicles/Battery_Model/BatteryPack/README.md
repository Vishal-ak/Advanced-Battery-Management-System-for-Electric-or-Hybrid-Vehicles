%===========================================================

% BATTERY DESIGNER

%

% Designs a battery pack by comparing commercial battery

% packs with a custom optimized design and generating a

% complete design report.

%

% Syntax

% ------

% Report = BatteryDesigner(targetVoltage,targetCapacity)

%

% Inputs

% ------

% targetVoltage  : Desired battery pack voltage (V)

% targetCapacity : Desired battery pack capacity (Ah)

%

% Outputs

% -------

% Report : Battery design report structure

%

% Example

% -------

% Report = BatteryDesigner(48,20);

%

% Author  : Vishal Mishra

% Project : EV\_HEV\_Platform

% Version : 1.0

% MATLAB  : R2025a

%===========================================================

%===========================================================

% CREATE BATTERY PACK

%

% Creates a battery pack using the specified battery cell

% and series/parallel configuration.

%

% Syntax

% ------

% Pack = createBatteryPack(Battery,Ns,Np)

%

% Inputs

% ------

% Battery : Battery cell structure

% Ns      : Number of series-connected cells

% Np      : Number of parallel-connected strings

%

% Outputs

% -------

% Pack : Battery pack structure

%

% Example

% -------

% Pack = createBatteryPack(Battery,13,6);

%

% Author  : Vishal Mishra

% Project : EV\_HEV\_Platform

% Version : 1.0

% MATLAB  : R2025a

%===========================================================

%===========================================================

% DESIGN BATTERY PACK

%

% Optimizes the series and parallel configuration of a

% Lithium-Ion battery pack for the required voltage and

% capacity.

%

% Syntax

% ------

% Pack = designPack(targetVoltage,targetCapacity)

%

% Inputs

% ------

% targetVoltage  : Desired battery voltage (V)

% targetCapacity : Desired battery capacity (Ah)

%

% Outputs

% -------

% Pack : Optimized battery pack structure

%

% Example

% -------

% Pack = designPack(48,20);

%

% Author  : Vishal Mishra

% Project : EV\_HEV\_Platform

% Version : 1.0

% MATLAB  : R2025a

%===========================================================

%===========================================================

% PACK VOLTAGE

%

% Calculates the battery pack voltage from the cell voltage.

%

% Syntax

% ------

% Vpack = packVoltage(CellVoltage,Pack)

%

% Inputs

% ------

% CellVoltage : Cell voltage (V)

% Pack        : Battery pack structure

%

% Outputs

% -------

% Vpack : Battery pack voltage (V)

%

% Example

% -------

% Vpack = packVoltage(3.7,Pack);

%

% Author  : Vishal Mishra

% Project : EV\_HEV\_Platform

% Version : 1.0

% MATLAB  : R2025a

%===========================================================

%===========================================================

% PACK CURRENT

%

% Calculates battery pack current from cell current.

%

% Syntax

% ------

% Ipack = packCurrent(CellCurrent,Pack)

%

% Inputs

% ------

% CellCurrent : Cell current (A)

% Pack        : Battery pack structure

%

% Outputs

% -------

% Ipack : Battery pack current (A)

%

% Example

% -------

% Ipack = packCurrent(5,Pack);

%

% Author  : Vishal Mishra

% Project : EV\_HEV\_Platform

% Version : 1.0

% MATLAB  : R2025a

%===========================================================

%===========================================================

% PACK POWER

%

% Calculates battery pack power.

%

% Syntax

% ------

% Power = packPower(Voltage,Current)

%

% Inputs

% ------

% Voltage : Pack voltage (V)

% Current : Pack current (A)

%

% Outputs

% -------

% Power : Battery pack power (W)

%

% Example

% -------

% Power = packPower(V,I);

%

% Author  : Vishal Mishra

% Project : EV\_HEV\_Platform

% Version : 1.0

% MATLAB  : R2025a

%===========================================================

%===========================================================

% PACK ENERGY

%

% Calculates battery pack energy in Wh and kWh.

%

% Syntax

% ------

% \[Wh,kWh] = packEnergy(Voltage,Capacity)

%

% Inputs

% ------

% Voltage  : Pack voltage (V)

% Capacity : Pack capacity (Ah)

%

% Outputs

% -------

% Wh  : Energy (Wh)

% kWh : Energy (kWh)

%

% Example

% -------

% \[Wh,kWh] = packEnergy(48,20);

%

% Author  : Vishal Mishra

% Project : EV\_HEV\_Platform

% Version : 1.0

% MATLAB  : R2025a

%===========================================================

%===========================================================

% VALIDATE BATTERY PACK

%

% Validates a battery pack against electrical, thermal and

% physical engineering constraints.

%

% Syntax

% ------

% Result = validatePack(Pack)

%

% Inputs

% ------

% Pack : Battery pack structure

%

% Outputs

% -------

% Result : Validation report

%

% Example

% -------

% Result = validatePack(Pack);

%

% Author  : Vishal Mishra

% Project : EV\_HEV\_Platform

% Version : 1.0

% MATLAB  : R2025a

%===========================================================



