# Panasonic NCR18650B — Reference-Cell Specification

This document separates manufacturer-referenced ratings from project model assumptions. Use the exact Panasonic datasheet revision included in the adjacent `Datasheet` directory when making design decisions.

## Reference identity

| Item | Value |
|---|---|
| Manufacturer | Panasonic |
| Model | NCR18650B |
| Format | Cylindrical 18650 |
| Chemistry | Lithium-ion; cathode chemistry is not asserted where the referenced datasheet does not specify it |

## Manufacturer-referenced specifications

| Parameter | Value | Unit | Basis |
|---|---:|---|---|
| Nominal voltage | 3.60 | V | Datasheet nominal rating |
| Typical capacity | 3.35 | Ah | At 25 °C under stated test conditions |
| Minimum capacity | 3.25 | Ah | At 25 °C under stated test conditions |
| Rated capacity | 3.20 | Ah | At 20 °C under stated test conditions |
| Charging voltage | 4.20 | V | CC-CV |
| Standard charge current | 1.625 | A | Manufacturer standard value |
| Charge below 10 °C | 0.25C | C-rate | Datasheet footnote; use reduced current below 10 °C |
| Discharge cutoff voltage | 2.50 | V | Datasheet test condition |
| Maximum cell mass | 48.5 | g | Confirm datasheet revision and tube configuration |
| Gravimetric energy density | 243 | Wh/kg | Datasheet reference value |
| Volumetric energy density | 676 | Wh/L | Bare-cell datasheet reference value |
| Charge ambient temperature | 0 to 45 | °C | Manufacturer operating condition |
| Discharge ambient temperature | −20 to 60 | °C | Manufacturer operating condition |

## Project runtime configuration

The active MATLAB initializer is `Parameters/initBattery.m`.

| Parameter | Configured value | Unit | Status |
|---|---:|---|---|
| Nominal voltage | 3.60 | V | Aligned with datasheet |
| Maximum voltage | 4.20 | V | Datasheet charge voltage |
| Cutoff voltage | 2.50 | V | Datasheet discharge condition |
| Design capacity | 3.35 | Ah | Typical capacity |
| InternalResistance | 0.050 | Ω | Project parameter; not a fixed manufacturer rating |
| ECM R0 | 0.045 | Ω | Preliminary model parameter; requires identification |
| ECM R1 | 0.012 | Ω | Preliminary model parameter |
| ECM C1 | 2400 | F | Preliminary model parameter |
| ECM R2 | 0.015 | Ω | Preliminary model parameter |
| ECM C2 | 8000 | F | Preliminary model parameter |
| Standard charge current | 1.625 | A | Datasheet standard current |
| Low-temperature charge threshold | 10 | °C | Below this point use 0.25C |
| Low-temperature charge current | 0.8375 | A | 0.25 × 3.35 Ah, derived per cell |
| Maximum discharge current | 5.00 | A | Conservative project model limit; not a datasheet maximum rating |
| Cell mass | 48.5 | g | Configured maximum-mass assumption |
| Diameter | 18.25 | mm | Bare-cell geometric assumption |
| Height | 65.10 | mm | Bare-cell geometric assumption |
| Specific heat | 900 | J/(kg·K) | Project thermal assumption |
| Thermal resistance | 5 | K/W | Project thermal assumption |
| Initial temperature | 25 | °C | Simulation initial condition |

## OCV data

The runtime initializer reads `Data/OCV_SOC.csv`. The repository also contains charge/discharge-related OCV files and a processing script. Before using the table as reference or validation data, document its exact source, test temperature, rest duration, charge/discharge direction, SOC reference, preprocessing and applicable usage rights.

The CSV file's presence does not establish that data was measured by this project or is manufacturer-published.

## Parameter consistency and calibration

The initializer retains `InternalResistance=0.050 Ω` separately from ECM `R0=0.045 Ω`. The ECM parameters are not specified by the cell datasheet and must be identified from pulse/dynamic cell tests. Do not present either resistance value as a universal manufacturer rating.

The configured cell discharge current of 5 A is a project-level modelling limit. The standard charge-current reference is 1.625 A per cell. In an ideal six-parallel configuration, this scales to 9.75 A pack current; real pack limits must also account for cell mismatch, interconnects, fusing, temperature and BMS design.

## Datasheet source

The repository includes manufacturer-reference PDF files in the `Datasheet` directory. A Panasonic NCR18650B datasheet hosted by a distributor also lists the relevant 3.6 V nominal, 3.35 Ah typical, 3.25 Ah minimum, 4.2 V charge, 1.625 A standard charge-current and temperature conditions: [NCR18650B datasheet PDF](https://www.batteryspace.com/prod-specs/NCR18650B.pdf). Use the included local PDF revision as the primary project reference and verify exact test conditions.

## Usage

```matlab
Battery = initBattery();
disp(Battery)
```
