# Advanced Battery Management System for Electric and Hybrid Vehicles
## Project Technical Report — Repository Audit Revision

**Report date:** 17 November 2026  
**Implementation language:** MATLAB  
**Reference cell:** Panasonic NCR18650B  
**Repository:** [Advanced-Battery-Management-System-for-Electric-or-Hybrid-Vehicles](https://github.com/Vishal-ak/Advanced-Battery-Management-System-for-Electric-or-Hybrid-Vehicles)  
**Report status:** Source-audited; audit-branch corrections prepared; MATLAB execution and experimental validation pending.

---

## Abstract

This project is an educational MATLAB implementation for lithium-ion cell and battery-pack modelling. It provides a reference-cell parameter set, tabulated open-circuit-voltage lookup, first- and second-order Thevenin equivalent-circuit models, Coulomb-counting state-of-charge integration, a lumped thermal model, series-parallel pack calculations, heuristic pack sizing, a commercial-pack comparison workflow, simplified passive-balancing and regenerative-current algorithms, and simulation plots.

A repository audit identified code/documentation drift and integration defects. The audit branch adds missing 2RC helper functions, stricter input and OCV-table validation, more robust pack-database unit parsing, a corrected commercial/custom comparison pathway, pack-scaled dynamic simulation, and a MATLAB dashboard connected to the simulation functions. The reference-cell nominal voltage was reconciled to the included Panasonic NCR18650B datasheet.

The project remains a simulation and learning platform. The code has not been executed in MATLAB as part of this audit, and no cell test campaign, independent model validation, hardware validation, functional-safety assessment, or vehicle testing is claimed.

## 1. Problem statement

A battery management system must estimate battery state and monitor electrical and thermal operating conditions. At the modelling level, an engineering BMS study needs a consistent cell representation, a series-parallel pack abstraction, current-driven state updates, thermal response, pack-level scaling, and a repeatable way to inspect simulation behaviour.

The repository addresses these needs through MATLAB functions and demonstration scripts. It does not implement a production BMS controller or a physical battery-management ECU.

## 2. Project objectives and implemented scope

The current source tree implements the following model and utility groups:

1. **Cell data and initialization:** Panasonic NCR18650B project parameter initialization and an OCV–SOC lookup table.
2. **Electrical model:** First-order Thevenin ECM (1RC) and optional second-order Thevenin ECM (2RC).
3. **SOC calculation:** Coulomb-counting integration using current, elapsed time, and nominal design capacity.
4. **Thermal model:** Single-node lumped thermal response with ohmic heat generation.
5. **Battery-pack model:** Series-parallel pack construction, electrical/energy/mass calculations, and consistency validation.
6. **Pack design:** Bounded heuristic search for a series-parallel configuration meeting nominal-voltage and capacity targets.
7. **Commercial-pack comparison:** Workbook loading, normalization, ranking and a custom-versus-commercial comparison report.
8. **Supervisory demonstrations:** Idealized passive shunt balancing and simplified regenerative-braking current limits.
9. **Simulation and reporting:** Constant-discharge, constant-charge, step, pulse and synthetic current profiles, plots, automated-test files and a MATLAB dashboard added on the audit branch.

### Explicitly not established as delivered features

The verified core implementation does not establish a validated EKF SOC estimator, rest-based OCV correction, SOH/aging estimator, fault-diagnosis system, safety-qualified protection architecture, active thermal-management controller, thermal-runaway predictor, or integrated Simulink model. Do not present these as completed features without adding source code, tests and supporting evidence.

## 3. Reference-cell specification

The reference cell is Panasonic NCR18650B. Values below separate manufacturer-published cell ratings from project-specific modelling assumptions.

| Parameter | Value | Basis |
|---|---:|---|
| Nominal voltage | 3.6 V | Manufacturer datasheet |
| Typical capacity | 3.35 Ah | At 25 °C, stated datasheet condition |
| Minimum capacity | 3.25 Ah | At 25 °C, stated datasheet condition |
| Rated capacity | 3.20 Ah minimum | At 20 °C, stated datasheet condition |
| Charging voltage | 4.20 V | Manufacturer CC-CV charge specification |
| Standard charge current | 1.625 A | Manufacturer standard value |
| Discharge cutoff | 2.50 V | Datasheet discharge test condition |
| Charge ambient temperature | 0 to 45 °C | Datasheet condition |
| Low-temperature charging | 0.25C below 10 °C | Datasheet footnote |
| Discharge ambient temperature | −20 to 60 °C | Datasheet condition |
| Maximum mass | 48.5 g | Datasheet reference |
| Volumetric energy density | 676 Wh/L | Bare-cell basis |
| Gravimetric energy density | 243 Wh/kg | Datasheet reference |

The current initializer uses the 3.6 V nominal voltage, 3.35 Ah typical capacity, 3.25 Ah minimum capacity, 4.2 V maximum/charge voltage, 2.5 V cutoff and 1.625 A standard charge current.

The configured 5 A per-cell discharge limit is a conservative project model limit. It is not claimed as the manufacturer's maximum continuous discharge rating. ECM resistance/capacitance values and thermal parameters are project modelling inputs requiring cell characterization.

Two resistance fields remain distinct: `InternalResistance=0.050 Ω` and ECM `R0=0.045 Ω`. Their values must be reconciled through traceable cell characterization; neither should be represented as a universal fixed cell resistance.

The OCV–SOC dataset is stored in `Cell_Library/Panasonic_NCR18650B/Data/OCV_SOC.csv`. The file's source, test temperature, rest period, charge/discharge direction, SOC reference method and preprocessing must be documented before it is used as a validation dataset.

## 4. Model architecture

### 4.1 Electrical equivalent-circuit model

The 1RC Thevenin cell model consists of an OCV source, series ohmic resistance (R_0), and one polarization branch (R_1-C_1).

With positive current defined as discharge:

[
V_t=V_{OC}(SOC)-I R_0-V_{RC}
]

The polarization voltage follows:

[
\frac{dV_{RC}}{dt}=-\frac{V_{RC}}{R_1C_1}+\frac{I}{C_1}
]

For a zero-order-held current over a time step (Delta t), the exact discrete update is:

[
V_{RC,k+1}=e^{-\Delta t/(R_1C_1)}V_{RC,k}
+R_1\left(1-e^{-\Delta t/(R_1C_1)}\right)I_k
]

The 2RC model adds a second independent polarization branch:

[
V_t=V_{OC}(SOC)-IR_0-V_{RC1}-V_{RC2}
]

The audit branch adds the previously missing 2RC branch-update and terminal-voltage helper functions. The second branch parameters are preliminary, and model order alone does not demonstrate improved accuracy.

The ECM returns an unclipped voltage prediction and status flags. Voltage clipping is deliberately avoided because it could hide a predicted limit violation. The ECM's status flags do not, by themselves, constitute a complete protection response.

### 4.2 State-of-charge calculation

The delivered core estimator is Coulomb counting:

[
SOC_{k+1}=\operatorname{clip}_{[0,1]}
\left(SOC_k-\frac{I_k\Delta t}{3600Q_{Ah}}\right)
]

where current is in amperes, time is in seconds and capacity is in ampere-hours. Positive current reduces SOC; negative current increases SOC.

The OCV lookup provides (V_{OC}) to the ECM for a supplied SOC. It does **not** by itself perform rested-voltage SOC correction. The Coulomb-counting implementation does not include coulombic efficiency, sensor bias, self-discharge, capacity fade or uncertainty estimation. These are limitations, not hidden features.

### 4.3 Thermal model

The single-node lumped thermal balance is:

[
m c_p\frac{dT}{dt}=\dot Q_{gen}-\frac{T-T_{amb}}{R_{th}}
]

The current heat-generation function uses:

[
\dot Q_{gen}=I^2R_0
]

The temperature state is advanced using explicit Euler integration. The model omits reversible entropic heat, temperature-dependent cell properties, internal temperature gradients, cooling-system dynamics and thermal-runaway physics. Time-step adequacy and thermal parameter identification require separate validation.

### 4.4 Pack scaling

For (N_s) cells in series and (N_p) parallel strings, with identical cells and ideal current sharing:

[
V_{pack}=N_sV_{cell},\qquad Q_{pack}=N_pQ_{cell}
]

[
R_{pack}=R_{cell}\frac{N_s}{N_p},\qquad
N_{cells}=N_sN_p
]

The pack current is the sum of the parallel-string currents; therefore the ideal per-cell current used by the cell model is:

[
I_{cell}=\frac{I_{pack}}{N_p}
]

These relationships do not include cell mismatch, busbar and interconnect losses, contact resistance, fusing, cooling, current-sharing imbalance or pack-level dynamic constraints.

## 5. Pack calculation examples

### 5.1 13S6P reference configuration

Using 3.6 V nominal voltage and 3.35 Ah typical capacity:

| Quantity | Calculation | Result |
|---|---|---:|
| Total cells | 13 × 6 | 78 |
| Nominal voltage | 13 × 3.6 V | 46.8 V |
| Maximum voltage | 13 × 4.2 V | 54.6 V |
| Cutoff voltage | 13 × 2.5 V | 32.5 V |
| Capacity | 6 × 3.35 Ah | 20.1 Ah |
| Nominal energy | 46.8 V × 20.1 Ah | 940.68 Wh |
| Standard charge-current arithmetic | 6 × 1.625 A | 9.75 A |
| Configured discharge-current limit | 6 × 5 A per cell | 30 A |

The 13S6P pack is a 48 V-class configuration; its calculated nominal voltage is 46.8 V, not 48.1 V. The 9.75 A standard charge-current result assumes ideal equal current sharing and must be reduced below 10 °C according to the cell datasheet's 0.25C instruction. At 0.25C per cell, the six-parallel pack current is (6\times0.25\times3.35=5.025\,A).

The 30 A discharge value is a project limit derived from the configured 5 A per-cell limit. It is not a manufacturer maximum-current claim.

### 5.2 Heuristic design example for a 48 V, 20 Ah target

With the current 3.6 V, 3.35 Ah reference cell, a feasible minimum configuration in the bounded search window is 14S6P:

| Quantity | Result |
|---|---:|
| Total cells | 84 |
| Nominal voltage | 50.4 V |
| Maximum voltage | 58.8 V |
| Cutoff voltage | 35.0 V |
| Capacity | 20.1 Ah |
| Nominal energy | 1,013.04 Wh |

This is a heuristic configuration, not a globally optimal or application-qualified design. The current search objective primarily weighs voltage mismatch, capacity mismatch and estimated mass. It does not prove thermal, mechanical, electrical, cost or safety feasibility.

## 6. Dynamic simulation and dashboard

### 6.1 Pack/cell current consistency

The original dynamic ECM demonstration applied a synthetic 8–30 A drive-cycle profile directly to a single-cell ECM even though the configured project discharge limit was 5 A per cell. Those original saved dynamic plots are therefore not suitable as representative operation of the selected cell.

The audit branch introduces `simulateBatteryPack.m`. It:
- Interprets profile current as pack current.
- Scales discharge and charge requests to configured project limits.
- Converts pack current to per-cell current by dividing by (N_p).
- Applies the separate low-temperature 0.25C charge limit below 10 °C.
- Inhibits charging outside the configured charge-temperature range and inhibits discharge outside the configured discharge-temperature range.
- Integrates cell SOC and lumped temperature and calculates pack voltage from series cell voltage.
- Limits charge/discharge current each step to prevent SOC crossing the configured operating window.\n- Returns current, voltage, SOC, temperature and limit-status histories, including SOC-boundary current limiting.

These behaviours are simulation-side constraints for demonstration and testing. They are not a certified BMS protection algorithm.

### 6.2 Interactive MATLAB dashboard

The original repository tree did not contain a MATLAB dashboard application. The audit branch adds `BMSDashboard.m`, which uses the simulation service and provides:

- Editable series and parallel cell counts.
- Initial SOC and cell temperature inputs.
- Ambient temperature, time step and simulation duration.
- Synthetic drive-cycle, constant-discharge, constant-charge, step-discharge and pulse-discharge profiles.
- Pack-current and cell-current plot.
- Pack terminal-voltage plot with configured maximum/cutoff reference lines.
- Coulomb-counting SOC plot.
- Lumped cell-temperature plot.
- Run summary with SOC, voltage range, peak temperature, current range, temperature-based inhibition, low-temperature charge derating, SOC-boundary limiting and voltage-limit counts.
- CSV export of the time-series results.

The dashboard is an offline MATLAB simulation interface. It does not communicate with a real battery pack, BMS ECU, sensors, CAN bus or charger. It has not been executed in MATLAB during this audit; UI compatibility and callback behaviour remain to be verified in the target MATLAB release.

## 7. Repository audit findings and corrections

The following issues were identified in the original repository and corrections are prepared on the audit branch:

| Finding | Correction prepared |
|---|---|
| 2RC ECM called helper functions absent from the tracked source tree | Added independent 2RC state-update and terminal-voltage functions |
| ECM and SOC public functions accepted malformed inputs | Added finite-scalar, domain and parameter validation |
| OCV table was not fully checked before interpolation | Added column, shape, finite-value, monotonic-SOC and domain validation |
| Legacy cell setup script referred to undefined `Battery.NominalCapacity` | Replaced duplicated parameter arithmetic with canonical initializer and pack builder |
| Legacy reference-pack scripts used a different temporary RC parameter set | Changed them to use the canonical runtime initializer |
| Pack database removed the `Ah` substring before checking `mAh` | Reworked parsing to recognize `mAh` first and handle grams/kilograms explicitly |
| Pack recommendation could divide by zero during metric normalization | Added zero-range handling, finite-row filtering, input validation and deterministic sorting |
| Commercial recommendation returned a table, but comparison code expected a scalar structure | Normalized the selected table row before constructing the comparison report |
| Commercial and custom energy-density values used different volume bases | Reported separately instead of directly comparing them |
| Test runner did not restore MATLAB's original current folder | Added cleanup-based folder restoration |
| Dynamic profile current was treated as single-cell current | Added pack-scaled simulation and corrected the dynamic demo |
| Regenerative current did not consistently apply the cell's low-temperature charge instruction | Added pack-level 0.25C limit below 10 °C |
| No interactive dashboard existed | Added a MATLAB simulation dashboard and CSV export on the audit branch |

## 8. Software testing status

Automated test files are present in `Tests/Automated_Test_File/`. The audit branch adds coverage for:
- Invalid ECM, RC and SOC inputs.
- OCV table validation.
- 2RC zero-current response and voltage-limit reporting.
- NCR18650B pack arithmetic and bounded pack sizing.
- Pack current to per-cell current conversion.
- Low-temperature charge-current derating and charge inhibition.
- Commercial database parsing of mAh/Ah, g/kg and dimensions.
- Passive balancing and regenerative-current constraints.

**No MATLAB or GNU Octave test execution was performed in this audit environment.** The presence of test functions is not evidence they pass. Do not publish a pass percentage or claim successful runtime verification until the suite has been executed in MATLAB.

Run from the canonical `Battery_Model` folder:

```matlab
projectPaths = setupProject();
results = runAllTests();
disp(results);
```

Then run the dashboard:

```matlab
app = BMSDashboard();
```

Record MATLAB release, operating system, date, total tests, passed/failed/incomplete counts, warnings and any UI errors.

## 9. Known engineering limitations and remaining work

1. **Cell characterization:** Verify the exact cell variant and datasheet revision. Identify R0/R1/C1 and optional R2/C2 from pulse data at several SOC and temperature points.
2. **OCV dataset provenance:** Record test temperature, rest duration, charge/discharge direction, SOC reference method, source and preprocessing. Add a rest-detection OCV correction only if it is actually implemented and validated.
3. **SOC accuracy:** Compare Coulomb-counting estimates against a trusted reference on independent data and quantify drift, bias and error.
4. **Thermal calibration:** Identify thermal capacity/resistance and validate temperature response. Check time-step convergence and acknowledge omitted reversible heat and internal gradients.
5. **Pack design constraints:** Add explicit application constraints for voltage, current, mass, cooling, thermal range, enclosure, interconnects, fusing and service conditions.
6. **Commercial database quality:** Verify every record's source, date, unit convention, completeness and whether dimensions refer to a complete pack. Execute the recommender against the actual workbook and inspect the ranked output.
7. **Balancing validation:** Estimate shunt resistor dissipation, temperature rise, energy loss and balancing duration. Validate the balancing policy against manufacturer limits.
8. **Regenerative acceptance:** The current logic is a simplified supervisory estimate. Replace it with experimentally validated charge acceptance across SOC, temperature and cell age before performance claims.
9. **Dashboard runtime:** Execute the UI in the target MATLAB release; verify controls, plots, error paths and CSV export.
10. **Hardware and safety engineering:** Add sensor/actuator interfaces, fault handling, protection architecture, hazard analysis and appropriate verification before considering hardware implementation. No ISO 26262 compliance is claimed.

## 10. Claims not supported by this project state

Do not claim:
- EKF SOC estimation or an EKF accuracy improvement.
- SOH/aging estimation or remaining-useful-life prediction.
- Experimental SOC, voltage or temperature accuracy without measured validation.
- Measured regenerative-energy recovery or passive-balancing improvement percentages.
- WLTP/UDDS validation; the included current generator is synthetic, not an official drive-cycle trace.
- Fault diagnosis, thermal-runaway prediction, functional-safety compliance, ISO 26262 compliance, certification or production readiness.

## 11. Conclusion

The repository contains a meaningful MATLAB battery-modeling foundation, not a fully validated production BMS. The main modelling blocks and pack-design workflow are present, but their parameter provenance and predictive performance need experimental evidence. The audit branch addresses several source-level integration defects, corrects the reference-cell nominal-voltage basis, introduces a consistent pack-to-cell simulation service and adds the missing interactive dashboard.

The next completion gate is a real MATLAB run of the automated test suite and dashboard, followed by independent cell-data calibration and validation. Until those steps are complete, report the project as an **implemented educational battery modelling and simulation platform undergoing software and engineering validation**.

## References

1. Panasonic NCR18650B lithium-ion cell datasheet included in `Cell_Library/Panasonic_NCR18650B/Datasheet/`. A readable copy of the one-page specification is available [here](https://e2e.ti.com/cfs-file/__key/communityserver-discussions-components-files/196/Panasonic-NCR18650B-datasheet.pdf).
2. MATLAB source modules, unit-test files, reference-cell data and pack database in this repository. See [Model Reference](MODEL_REFERENCE.md), [Validation Status](VALIDATION_STATUS.md), [Execution Guide](../EXECUTION_GUIDE.md) and [Cell Specification](../Cell_Library/Panasonic_NCR18650B/Documentation/Cell%20Specification.md).
