


# 🔋 Advanced Battery Management System for Electric & Hybrid Vehicles

A modular MATLAB-based battery engineering and Battery Management System (BMS)
platform for designing, modeling, simulating, validating, and analyzing
Lithium-Ion battery cells and battery packs for Electric Vehicles (EVs) and
Hybrid Electric Vehicles (HEVs).

---

# Project Overview

This project provides a modular engineering framework for battery cell
modeling, battery-pack design, simulation, State of Charge (SOC) estimation,
thermal analysis, commercial battery-pack analysis, optimization, and
validation.

The platform includes:

- Battery Cell Modeling
- Panasonic NCR18650B Cell Library
- Open-Circuit Voltage (OCV) - SOC Lookup Model
- First-Order Equivalent Circuit Model (1RC ECM)
- Thermal Model
- Battery Pack Design
- User-Defined Battery Pack Construction
- Pack-Level Electrical API
- Commercial Battery Pack Database
- Battery Pack Recommendation
- Battery Pack Optimization
- Battery Pack Validation
- State of Charge (SOC) Estimation
- Dynamic Current Profile Simulation

The objective is to develop a reusable MATLAB-based battery engineering
platform that can be further extended toward a complete Battery Management
System and EV/HEV simulation framework.

---

# Project Structure

```markdown
Battery_Model
│
├── BatteryPack
│   ├── BatteryDesigner.m
│   ├── createBatteryPack.m
│   ├── designPack.m
│   ├── packCurrent.m
│   ├── packEnergy.m
│   ├── packPower.m
│   ├── packVoltage.m
│   ├── README.md
│   └── validatePack.m
│
├── Cell_Library
│   └── Panasonic_NCR18650B
│       ├── Data
│       ├── Datasheet
│       ├── Documentation
│       ├── Results
│       └── Scripts
│           └── initCell.m
│
├── Cell_Model
│   ├── ECM
│   │   ├── batteryECM.m
│   │   ├── terminalVoltage.m
│   │   └── updateRCVoltage.m
│   │
│   └── Thermal
│       ├── calcHeatGeneration.m
│       └── updateTemperature.m
│
├── Pack_Database
│   ├── cleanPackDatabase.m
│   ├── loadPackDatabase.m
│   ├── Packdata.xlsx
│   └── recommendPack.m
│
├── Parameters
│   ├── initBattery.m
│   └── README.md
│
├── Results
│
├── Scripts
│
├── Simulation
│   └── CurrentProfile
│       ├── constantCurrent.m
│       ├── driveCycleCurrent.m
│       ├── pulseCurrent.m
│       ├── README.md
│       └── stepCurrent.m
│
├── SOC
│
├── Tests
│   ├── testBatteryDesigner.m
│   ├── testBatteryPack.m
│   ├── testDesignPack.m
│   ├── testDynamicECM.m
│   ├── testECM.m
│   ├── testPackAPI.m
│   ├── testPackDatabase.m
│   ├── testRecommendPack.m
│   ├── testSOC.m
│   └── testTemperature.m
│
└── Validation
```

---

# Features

## 🔋 Battery Cell Model

The platform uses the Panasonic NCR18650B cylindrical Lithium-Ion cell as
the reference battery cell.

The cell model includes:

- Cell manufacturer and identification
- Lithium-Ion cell chemistry
- Nominal voltage
- Maximum voltage
- Cutoff voltage
- Battery capacity
- Internal resistance
- Charge current
- Maximum discharge current
- Cell mass and dimensions
- Cell energy
- Gravimetric energy density
- Volumetric energy density
- OCV-SOC lookup data
- Thermal parameters
- Initial SOC and SOH
- ECM parameters

The battery parameters are initialized using:

```matlab
Battery = initBattery();
```

---

# ⚡ Battery Pack Design

The battery-pack module supports both automatic pack sizing and
user-defined pack construction.

## Automatic Pack Design

The required nominal voltage and capacity can be specified as design
requirements:

```matlab
Pack = designPack(48,20);
```

For the reference Panasonic NCR18650B cell, the design procedure selects:

```text
Target Voltage      : 48 V
Target Capacity     : 20 Ah

Configuration       : 13S6P
Total Cells         : 78

Nominal Voltage     : 48.10 V
Capacity            : 20.10 Ah
Energy              : 966.81 Wh
```

## User-Defined Pack Construction

A specific series-parallel configuration can also be directly created:

```matlab
Battery = initBattery();

Ns = 80;
Np = 2;

Pack = createBatteryPack(Battery,Ns,Np);
```

where:

- `Ns` = number of cells connected in series
- `Np` = number of cells connected in parallel

The series connection determines the pack voltage, while the parallel
connection determines the pack capacity.

---

# 🔌 Battery Pack API

The Pack API provides functions for calculating important pack-level
electrical and energy parameters.

Available functions:

```matlab
packVoltage()
packCurrent()
packPower()
packEnergy()
```

Example:

```matlab
Battery = initBattery();

Pack = createBatteryPack(Battery,13,6);

Vpack = packVoltage(Battery.NominalVoltage,Pack);
Ipack = packCurrent(Battery.MaxDischargeCurrent,Pack);
Power = packPower(Vpack,Ipack);

[EWh,EkWh] = packEnergy(Vpack,Pack.Capacity);
```

The pack model provides:

- Nominal voltage
- Maximum voltage
- Cutoff voltage
- Capacity
- Maximum current
- Power
- Energy
- Energy density
- Pack mass
- Specific energy
- Total cell count
- Series-parallel configuration

---

# 🔬 Equivalent Circuit Model (ECM)

The project implements a **First-Order RC Equivalent Circuit Model (1RC ECM)**
to represent the electrical behavior of the battery cell.

The ECM includes:

- Open-Circuit Voltage (OCV)
- SOC-dependent OCV
- Ohmic resistance
- RC polarization branch
- Terminal voltage calculation
- RC voltage update
- Dynamic battery response

The ECM can be evaluated using:

```matlab
[Voltage,Vrc,OCV] = batteryECM( ...
    SOC, ...
    Current, ...
    Vrc, ...
    dt, ...
    Battery);
```

The model is tested using both constant-current and time-varying current
profiles.

---

# 🌡️ Thermal Model

The thermal module evaluates battery heat generation and temperature
variation during operation.

The thermal model includes:

- Heat generation calculation
- Temperature update
- Specific heat
- Thermal resistance
- Initial temperature
- Temperature limits

Core functions:

```matlab
calcHeatGeneration()
updateTemperature()
```

The thermal model can be used to study battery temperature rise under
different current conditions.

---

# 📊 State of Charge (SOC) Estimation

The platform implements **Coulomb Counting** for SOC estimation.

SOC is updated using:

- Previous SOC
- Battery current
- Sampling time
- Battery capacity

Example:

```matlab
SOC_new = coulombCounting( ...
    SOC, ...
    Current, ...
    dt, ...
    Capacity);
```

SOC behavior can be evaluated under different discharge profiles.

---

# 🚗 Current Profile Simulation

The dynamic battery model supports multiple current profiles:

```text
constantCurrent()
stepCurrent()
pulseCurrent()
driveCycleCurrent()
```

### Available Profiles

- Constant-current discharge
- Step-current discharge
- Pulse-current discharge
- Drive-cycle current

These profiles are used to evaluate battery:

- Current response
- Terminal voltage
- Open-circuit voltage
- State of Charge

---

# 🗃️ Commercial Battery Pack Database

The project includes a commercial battery-pack database for pack
comparison and recommendation.

The database module supports:

- Commercial battery-pack data loading
- Data cleaning
- Parameter extraction
- Pack comparison
- Battery-pack recommendation

The database can be loaded using:

```matlab
PackDB = loadPackDatabase();
```

The first ten database records can be displayed using:

```matlab
disp(PackDB(1:10,:))
```

---

# ⭐ Battery Pack Recommendation

The recommendation engine evaluates available battery-pack configurations
against specified voltage and capacity requirements.

Example:

```matlab
Voltage = 48;
Capacity = 20;

Results = recommendPack(Voltage,Capacity);
```

The returned results include parameters such as:

- Configuration
- Nominal voltage
- Nominal capacity
- Pack weight
- Recommendation score

This allows suitable battery-pack configurations to be ranked according
to the specified requirements.

---

# 🧮 Integrated Battery Design Platform

The `BatteryDesigner()` function integrates the major battery-design
operations into a single workflow.

Example:

```matlab
Report = BatteryDesigner(48,20);
```

The integrated platform performs:

1. Design requirement definition
2. Battery-pack configuration selection
3. Battery-pack creation
4. Pack parameter calculation
5. Pack optimization
6. Battery-pack validation
7. Commercial pack comparison
8. Final recommendation

For the example requirement of 48 V and 20 Ah:

```text
Configuration        : 13S6P
Series Cells         : 13
Parallel Cells       : 6
Total Cells          : 78

Nominal Voltage      : 48.10 V
Maximum Voltage      : 54.60 V
Cutoff Voltage       : 32.50 V

Capacity             : 20.10 Ah
Energy               : 966.81 Wh
Energy               : 0.97 kWh

Pack Mass            : 3.78 kg
Specific Energy      : 255.57 Wh/kg
Energy Density       : 727.86 Wh/L
```

---

# ✅ Battery Pack Validation

The validation module checks the designed battery pack against defined
electrical, physical, thermal, and model parameters.

Validation checks include:

- Maximum voltage
- Capacity
- Maximum current
- Cell count
- Pack mass
- Energy
- ECM parameters
- Temperature limits
- Initial SOC
- Initial SOH

Example:

```matlab
validatePack(Pack);
```

The integrated battery designer can report:

```text
VALIDATION STATUS : PASSED
Errors             : 0
Warnings           : 0
```

---

# 🧪 Testing

Dedicated MATLAB test scripts are provided for validating individual
modules and the integrated platform.

The test suite includes:

```text
testBatteryDesigner.m
testBatteryPack.m
testDesignPack.m
testDynamicECM.m
testECM.m
testPackAPI.m
testPackDatabase.m
testRecommendPack.m
testSOC.m
testTemperature.m
```

The tests cover:

- Battery initialization
- Battery-pack construction
- Automatic pack design
- ECM behavior
- Dynamic ECM response
- Pack API calculations
- Commercial database processing
- Pack recommendation
- SOC estimation
- Thermal simulation
- Integrated battery design
- Battery-pack validation

---

# 💻 MATLAB Environment

Developed and tested using:

- MATLAB R2025a Update 1

The current implementation is primarily MATLAB-based. Additional MATLAB
toolboxes or Simulink-based models may be incorporated in future
development.

---

# 🚀 Quick Start

## 1. Initialize the Battery

```matlab
Battery = initBattery();
```

## 2. Design a Battery Pack

```matlab
Pack = designPack(48,20);
```

## 3. Validate the Pack

```matlab
validatePack(Pack);
```

## 4. Run the Integrated Designer

```matlab
Report = BatteryDesigner(48,20);
```

## 5. Load the Commercial Database

```matlab
PackDB = loadPackDatabase();
```

## 6. Generate Pack Recommendations

```matlab
Results = recommendPack(48,20);
```

---

# 📌 Example Output

For a target requirement of approximately 48 V and 20 Ah:

```text
Configuration       : 13S6P
Total Cells         : 78

Nominal Voltage     : 48.10 V
Maximum Voltage     : 54.60 V
Cutoff Voltage      : 32.50 V

Capacity            : 20.10 Ah
Energy              : 966.81 Wh

Pack Mass           : 3.78 kg
Specific Energy     : 255.57 Wh/kg
Energy Density      : 727.86 Wh/L

Validation Status   : PASSED
```

---

# 🔮 Future Work

The current platform provides a foundation for further development toward
a more comprehensive Battery Management System.

Planned extensions include:

- State of Health (SOH) estimation
- Battery aging and degradation modeling
- Cell balancing
- BMS protection algorithms
- Over-voltage protection
- Under-voltage protection
- Over-current protection
- Advanced thermal management
- Fast-charging model
- Thermal runaway detection
- Fault detection and diagnosis
- Battery diagnostics
- Simulink battery-pack implementation
- EV drive-cycle simulation
- HEV energy-management integration
- Motor and inverter integration
- Vehicle-dynamics integration
- Advanced SOC estimation

---

# 👨‍💻 Author

**Vishal Mishra**

B.Tech Electrical Engineering

Dr. B. R. Ambedkar National Institute of Technology Jalandhar

---

# 📄 License

This project is developed for educational and research purposes.
