# Panasonic NCR18650B — Reference-Cell Specification

This file summarizes the values currently configured by the project. It is not a substitute for the manufacturer datasheet. Consult the adjacent `Datasheet` folder and record the exact document revision and test conditions before asserting a value is manufacturer-guaranteed.

## Reference identity

| Item | Project reference |
|---|---|
| Manufacturer | Panasonic |
| Model | NCR18650B |
| Format | Cylindrical 18650 |
| Chemistry | NCA lithium-ion (project designation; verify variant documentation) |

## Current model initialization

The following values are set in `Parameters/initBattery.m`. They are **runtime model inputs**, not a guarantee that each value is a manufacturer specification.

| Parameter | Runtime value | Unit | Comment |
|---|---:|---|---|
| Nominal voltage | 3.70 | V | Project configuration; reconcile with selected datasheet |
| Maximum voltage | 4.20 | V | Configured upper voltage limit |
| Cutoff voltage | 2.50 | V | Configured lower voltage limit |
| Minimum capacity | 3.25 | Ah | Project parameter |
| Typical/design capacity | 3.35 | Ah | Used for pack calculations |
| Internal resistance field | 0.050 | Ω | Separate field; not the ECM R0 |
| ECM R0 | 0.045 | Ω | Used by 1RC and thermal heat-generation functions |
| ECM R1 | 0.012 | Ω | First polarization branch |
| ECM C1 | 2400 | F | First polarization branch |
| Optional ECM R2 | 0.015 | Ω | Preliminary second branch |
| Optional ECM C2 | 8000 | F | Preliminary second branch |
| Standard charge current | 1.65 | A | Project parameter; verify against datasheet |
| Maximum discharge current | 5.00 | A | Project parameter; verify rating and test conditions |
| Cell mass | 48.5 | g | Used in mass estimation |
| Diameter | 18.25 | mm | Geometric parameter |
| Height | 65.10 | mm | Geometric parameter |
| Specific heat | 900 | J/(kg·K) | Simplified thermal parameter |
| Thermal resistance | 5 | K/W | Simplified thermal parameter |
| Initial temperature | 25 | °C | Simulation initial condition |
| Configured operating temperature | −20 to 60 | °C | Model limits; verify applicability |

## OCV data

The runtime initializer reads:

`Data/OCV_SOC.csv`

The repository also contains charge/discharge-related OCV files and a processing script. Before using the table as reference or validation data, document its source, measurement temperature, rest duration, direction, SOC reference method, preprocessing and any permission/license conditions. The CSV's existence does not establish provenance or that it was measured by this project.

## Known inconsistencies requiring resolution

- `InternalResistance` is 0.050 Ω, while ECM `R0` is 0.045 Ω.
- Legacy scripts use a temporary (R_1=0.0015\,\Omega), (C_1=35000\,F) instead of the current runtime initializer's (R_1=0.012\,\Omega), (C_1=2400\,F).
- Legacy `initCell.m` expects `Battery.NominalCapacity`, which does not exist in the current `initBattery.m` initializer.

Do not silently reconcile these by choosing a value without a traceable parameter source. Select one parameter set after reviewing the correct datasheet and cell test data, then update all legacy scripts and documentation from that source.

## Usage

```matlab
Battery = initBattery();
disp(Battery)
```
