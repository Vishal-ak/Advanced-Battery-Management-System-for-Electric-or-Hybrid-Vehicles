# Panasonic NCR18650B — Reference-Cell Specification

This file summarizes the cell assumptions used by this project. It is not a substitute for the manufacturer datasheet. Consult the PDF documents in the adjacent `Datasheet` directory for manufacturer specifications and test conditions.

## Reference identity

| Item | Project reference |
|---|---|
| Manufacturer | Panasonic |
| Model | NCR18650B |
| Format | Cylindrical 18650 |
| Chemistry | NCA lithium-ion (project designation) |

## Model parameters

The following values are configured in `Parameters/initBattery.m`. They are software model inputs and must not be represented as a complete transcription of the manufacturer's datasheet.

| Parameter | Current model value | Unit | Notes |
|---|---:|---|---|
| Nominal voltage | 3.70 | V | Project model assumption; confirm against exact cell datasheet revision |
| Maximum voltage | 4.20 | V | Configured upper voltage limit |
| Cutoff voltage | 2.50 | V | Configured lower voltage limit |
| Typical/design capacity | 3.35 | Ah | Used for pack calculations |
| Minimum capacity | 3.25 | Ah | Conservative project parameter |
| Standard charge current | 1.65 | A | Project model assumption |
| Maximum discharge current | 5.00 | A | Project model assumption; verify continuous rating and test conditions |
| Internal resistance | 0.050 | Ω | General parameter; ECM uses separate (R_0=0.045,Omega) |
| Cell mass | 48.5 | g | Used in mass estimate |
| Diameter | 18.25 | mm | Geometric parameter |
| Height | 65.10 | mm | Geometric parameter |
| Specific heat | 900 | J/(kg·K) | Simplified thermal-model parameter |
| Thermal resistance | 5 | K/W | Simplified thermal-model parameter |
| Initial temperature | 25 | °C | Simulation initial condition |
| ECM (R_0) | 0.045 | Ω | Ohmic resistance |
| ECM (R_1) | 0.012 | Ω | First polarization resistance |
| ECM (C_1) | 2400 | F | First polarization capacitance |
| Optional ECM (R_2) | 0.015 | Ω | Preliminary second branch; requires identification |
| Optional ECM (C_2) | 8000 | F | Preliminary second branch; requires identification |
| Operating temperature range | −20 to 60 | °C | Configured model limits; verify for use case |

## Data and provenance

The OCV–SOC table is loaded from:

`Data/OCV_SOC.csv`

Before using it for quantitative model validation, record its source, measurement temperature, rest duration, charge/discharge direction, SOC reference method and any preprocessing steps. The existence of a CSV file alone does not establish that the data is manufacturer-published or experimentally characterized by this project.

## Parameter consistency warning

Other project data files may contain different nominal voltage, resistance and current values. In particular, `Data/parameter.txt` is a separate reference-data file and is not automatically synchronized with `initBattery.m`. Treat `initBattery.m` as the current MATLAB runtime configuration; reconcile discrepancies against the official datasheet before making a final engineering parameter set.

## Usage

```matlab
Battery = initBattery();
disp(Battery)
```
