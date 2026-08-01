# 🔋 Advanced Battery Management System for Electric & Hybrid Vehicles

A modular MATLAB-based Battery Management System (BMS) platform for
designing, simulating and analyzing Lithium-Ion battery packs used in
Electric Vehicles (EVs) and Hybrid Electric Vehicles (HEVs).

---

## Project Overview

This project provides an engineering framework for battery pack design,
commercial battery pack recommendation, battery modeling and simulation.

The platform includes:

- Battery Cell Modeling
- Equivalent Circuit Model (ECM)
- Thermal Model
- Battery Pack Design
- Commercial Battery Pack Database
- Battery Pack Validation
- State of Charge (SOC) Estimation
- Current Profile Simulation

The objective is to build a reusable MATLAB toolbox that can later be
extended into a complete Battery Management System.

---

# Project Structure

```
Battery_Model
│
├── BatteryPack
│   ├── BatteryDesigner.m
│   ├── createBatteryPack.m
│   ├── designPack.m
│   ├── packVoltage.m
│   ├── packCurrent.m
│   ├── packPower.m
│   ├── packEnergy.m
│   └── validatePack.m
│
├── Cell_Library
│   └── Panasonic_NCR18650B
│
├── Cell_Model
│   ├── ECM
│   └── Thermal
│
├── Pack_Database
│
├── Parameters
│
├── Simulation
│
├── SOC
│
├── Tests
│
├── Results
│
├── Scripts
│
└── README.md
```

---

# Features

## Battery Cell

- Panasonic NCR18650B Cell Library
- Cell Parameters
- OCV-SOC Lookup Table
- Internal Resistance
- Cell Energy Calculation

---

## Battery Pack

- Custom Battery Pack Design
- Series/Parallel Configuration
- Pack Voltage
- Pack Capacity
- Pack Energy
- Pack Mass
- Pack Energy Density
- Pack Validation
- Pack Optimization

---

## Equivalent Circuit Model (ECM)

- First Order RC Model
- Terminal Voltage Calculation
- RC Voltage Update
- Dynamic Cell Behaviour

---

## Thermal Model

- Heat Generation
- Temperature Update
- Thermal Parameters

---

## Commercial Battery Database

- Excel Database
- Data Cleaning
- Automatic Parameter Extraction
- Battery Recommendation Engine

---

## State of Charge (SOC)

- Coulomb Counting

---

## Simulation

Current Profiles

- Constant Current
- Step Current
- Pulse Current
- Drive Cycle Current

---

# MATLAB Version

Developed using

- MATLAB R2025a Update 1

Toolboxes

- Simulink
- Simscape
- Simscape Electrical
- Simscape Battery
- Control System Toolbox

---

# Example

```matlab
Pack = designPack(48,20);

validatePack(Pack);

Report = BatteryDesigner(48,20);
```

---

# Example Output

```
Configuration : 13S6P

Nominal Voltage : 48.10 V

Capacity : 20.10 Ah

Energy : 966.81 Wh

Mass : 3.78 kg

Specific Energy : 255.57 Wh/kg
```

---

# Future Work

- State of Health (SOH)
- Battery Aging Model
- Cell Balancing
- BMS Protection Algorithms
- Fast Charging Model
- Thermal Runaway Detection
- Simulink Battery Pack
- EV Drive Cycle Simulation
- Fault Detection
- Battery Diagnostics

---

# Author

**Vishal Mishra**

B.Tech Electrical Engineering

Dr. B. R. Ambedkar National Institute of Technology Jalandhar

---

# License

This project is developed for educational and research purposes.
