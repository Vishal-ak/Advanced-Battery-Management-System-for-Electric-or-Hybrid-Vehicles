# Reference-cell data and model-parameter register

## Cell identity
Reference cell: Panasonic NCR18650B cylindrical lithium-ion cell.

## Manufacturer-referenced specification values
Values below are transcribed from the NCR18650B product data sheet, version 13.11 R1. They are specification values, not guarantees for an arbitrary sample.

| Parameter | Value | Condition / note |
|---|---:|---|
| Nominal voltage | 3.6 V | Manufacturer specification |
| Typical capacity | 3.35 Ah | At 25 °C |
| Minimum capacity | 3.25 Ah | At 25 °C |
| Rated capacity | 3.20 Ah minimum | At 20 °C; different test condition |
| Charge voltage | 4.20 V | CC-CV |
| Standard charge current | 1.625 A | Manufacturer specification |
| Discharge cutoff | 2.50 V | Manufacturer specification |
| Maximum weight | 48.5 g | Manufacturer specification |
| Bare-cell dimensions | 18.25 mm diameter, 65.10 mm height | Typical bare-cell dimensions; verify drawing before mechanical design |
| Operating temperature | Charge 0 to 45 °C; discharge -20 to 60 °C | Manufacturer specification |

Source: Panasonic/SANYO NCR18650B datasheet, version 13.11 R1:
https://e2e.ti.com/cfs-file/__key/communityserver-discussions-components-files/196/Panasonic-NCR18650B-datasheet.pdf

## Model inputs: provisional, not manufacturer-validated
ECM resistances and capacitances (R0, R1, C1, R2, C2), thermal resistance, specific heat and any single fixed current limit are model inputs. They must be identified or confirmed using traceable cell tests. The repository cell-library parameter file contains a 0.100 Ohm internal-resistance entry. Until its measurement method and conditions are documented, treat this as a provisional project-library value, not a guaranteed Panasonic datasheet value.

The canonical initializer uses one ohmic input consistently:
- Battery.InternalResistance is the project's current provisional ohmic-resistance input.
- Battery.R0 aliases that value for ECM and heat-generation calculations.
- Do not maintain a second independent hard-coded R0 value.

The 1RC/2RC polarization parameters remain provisional pending pulse-test identification. Parameters from another cell, temperature, SOC or test method are not automatically transferable.

## OCV-SOC table
Cell_Library/Panasonic_NCR18650B/Data/OCV_SOC.csv is loaded by initBattery. Its sample provenance, temperature, rest period, charge/discharge direction and SOC calibration must be documented before treating it as independent validation data. It is currently a model input, not proof of independent experimental validation.

## Interpretation rules
1. Do not conflate 3.6 V nominal voltage with OCV at a particular SOC.
2. Do not treat 3.35 Ah typical capacity as guaranteed capacity for every cell.
3. Separate manufacturer specifications from project assumptions and fitted ECM parameters.
4. Evaluate voltage prediction on measured data not used to fit ECM parameters.
5. A passing software test suite is not experimental validation or safety qualification.
