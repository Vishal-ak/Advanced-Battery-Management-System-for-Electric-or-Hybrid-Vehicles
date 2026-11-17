# Validation Status, Audit Findings and Remaining Work

**Audit date:** 17 November 2026  
**Base branch audited:** `main`  
**Correction branch:** `audit/engineering-consistency-and-docs`  
**Current state:** Corrections and dashboard are committed to the correction branch. They are not merged into `main`, and MATLAB execution has not been performed in this environment.

This register distinguishes source implementation, automated software testing, experimental model validation and safety qualification. These are separate evidence levels.

## 1. Implementation inventory

| Area | Current correction-branch status | Evidence / limitation |
|---|---|---|
| NCR18650B parameter initialization | Implemented | Nominal voltage and charge ratings aligned to included datasheet; ECM and thermal parameters remain project assumptions |
| OCV–SOC lookup | Implemented | Loaded and structurally validated; provenance and test conditions remain to be documented |
| 1RC Thevenin ECM | Implemented | Unit tests exist; no independent measured-data validation |
| 2RC Thevenin ECM | Implemented | Missing 2RC helper functions added; R2/C2 values preliminary |
| Coulomb-counting SOC | Implemented | No reference-instrument accuracy/drift validation |
| Rest-based OCV SOC correction | Not implemented | OCV lookup alone is not an online SOC correction method |
| EKF SOC estimator | Not established in core source | Do not claim as delivered |
| Lumped thermal model | Implemented | Single node, irreversible (I^2R_0) heat only; no measured calibration |
| SOH / aging estimator | Not established in core source | Do not claim as delivered |
| Pack construction and heuristic sizing | Implemented | Bounded heuristic; not global or safety-constrained |
| Commercial pack database and recommendation | Implemented | Parser hardened; workbook provenance and runtime output still need inspection |
| Custom/commercial BatteryDesigner report | Integration corrected on branch | Table-to-struct conversion added; end-to-end execution against workbook pending |
| Passive balancing | Implemented | Idealized shunt logic; no resistor thermal or hardware validation |
| Regenerative-braking current estimate | Implemented | Project SOC heuristic, voltage-headroom limit and datasheet temperature/low-temp current constraints; not electrochemical charge acceptance |
| Pack-scaled simulation service | Added | Converts pack current to per-cell current; applies temperature/low-temp charge limits and per-step SOC boundaries; needs MATLAB run |
| Dynamic ECM demonstration | Corrected | 13S6P profile maps pack current to cell current; saved legacy plot files have not yet been regenerated |
| Interactive MATLAB dashboard | Added as `BMSDashboard.m` | Includes constant-charge case and SOC-limit metrics/CSV; no MATLAB UI execution/interaction test yet |
| Dashboard CSV export | Added | Needs MATLAB runtime verification |
| Integrated Simulink model | Not present | No tracked `.slx` model |
| Safety-qualified BMS | Not established | No safety case, hazard analysis or certification evidence |

## 2. Confirmed findings and branch corrections

| Original finding | Correction prepared |
|---|---|
| 2RC model called helper functions that were absent | Added `updateRCVoltage_2RC.m` and `terminalVoltage_2RC.m` |
| ECM, SOC, thermal and pack utility functions had incomplete input checks | Added finite-scalar, parameter-domain, thermal and pack-API validation |
| OCV lookup data was used without structural checks | Added required-column, vector-shape, finite-data, monotonic-SOC and [0,1] range checks |
| Legacy reference-cell script used missing `Battery.NominalCapacity` | Replaced with the canonical initializer and pack builder |
| Old cell setup scripts duplicated a different temporary RC parameter set | Updated to use `initBattery.m` as the runtime parameter source |
| NCR18650B nominal voltage was set to 3.7 V | Corrected to 3.6 V in the runtime initializer |
| Pack-database parser checked/removes Ah before mAh | Reworked mAh/Ah parsing order and explicit g/kg conversion |
| Database metric normalization could divide by zero | Added zero-range normalization, filtering, and input validation |
| BatteryDesigner treated a returned table as a scalar struct | Normalized selected commercial row using `table2struct` |
| Commercial and custom energy-density values used unlike volume bases | Reports values separately, not as comparable metrics |
| Test runner left current directory changed | Added cleanup-based directory restoration |
| Dynamic current profile was fed directly into a single-cell ECM | Added pack-scale simulation service and corrected the demonstration |
| Regenerative current ignored low-temperature 0.25C instruction | Added pack-level low-temperature charge limit and corresponding tests |
| No dashboard application existed | Added offline MATLAB simulation dashboard with five profiles, current, voltage, SOC, temperature, SOC-limit metrics and CSV export |
| New simulation service was not on setup path | Added `Simulation` folder to `setupProject.m` |

## 3. Reference cell and pack arithmetic

The Panasonic NCR18650B datasheet used by the project identifies 3.6 V nominal voltage, 3.35 Ah typical capacity at 25 °C, 3.25 Ah minimum capacity at 25 °C, 3.20 Ah minimum rated capacity at 20 °C, 4.20 V charging voltage, 1.625 A standard charge current, a 0–45 °C charge-temperature range, and a 0.25C charge instruction below 10 °C. The discharge ambient-temperature range is −20 to 60 °C.

For a 13S6P configuration, ideal arithmetic using 3.6 V and 3.35 Ah gives 78 cells, 46.8 V nominal, 54.6 V maximum, 32.5 V cutoff, 20.1 Ah and 940.68 Wh nominal energy. Standard pack charge-current arithmetic is 9.75 A; below 10 °C, 0.25C per cell corresponds to 5.025 A for six parallel cells.

The configured 5 A per-cell discharge limit is a conservative project assumption, not a manufacturer maximum rating. No pack operating rating should be inferred from ideal cell-count arithmetic alone.

## 4. Dynamic simulation finding

The original dynamic profile reaches 30 A positive pack current and −8 A regenerative pack current. The original script applied those values directly to a single-cell ECM even though the configured project per-cell discharge limit was 5 A. The legacy dynamic plots were therefore generated outside the configured single-cell discharge limit.

The correction uses a 13S6P pack and:

[
I_{cell}=\frac{I_{pack}}{N_p}
]

The corrected 30 A pack discharge maps to 5 A per cell for six ideal parallel cells. The negative current is also distributed across the six parallel cells and limited by the standard/low-temperature charge rules. The script and the new reusable simulation service must still be executed in MATLAB; no new plot has been asserted as generated during this audit.

## 5. Dashboard audit

The original `main` tree had no dashboard application file. The correction branch adds `BMSDashboard.m` and the model service `Simulation/simulateBatteryPack.m`.

Dashboard features in source:
- Editable Ns/Np, initial SOC, cell/ambient temperature, time step and duration.
- Five profile selections: synthetic drive cycle, constant discharge, constant charge, step discharge and pulse discharge.
- Current, pack voltage, SOC and cell-temperature plots.
- SOC, voltage, temperature, current, temperature-based inhibition/derating, SOC-boundary limiting and voltage-flag summaries.
- CSV time-series export.
- Last completed run retrievable from `app.GetResults()`.

The dashboard is an offline, model-based interface. It has no real-time hardware acquisition, CAN/charger communication, contactor actuation, or safety controller. It has not been launched in the target MATLAB release. The following still need manual verification:
1. Figure layout and supported UI component compatibility.
2. Run callback, profile selection and invalid-input/error handling.
3. Voltage reference lines and plot scaling.
4. CSV path selection and exported data columns.
5. Retrieval of results through `app.GetResults()`.
6. Closing/reopening the application and rerunning multiple simulations.

## 6. Automated test status

Automated unit-test files are present under `Tests/Automated_Test_File/`. The correction branch adds coverage for:
- 1RC/2RC and RC state update inputs.
- OCV-table monotonicity and shape.
- Coulomb-counting sign, limits and input domains.
- Thermal heat generation and temperature response.
- Reference-cell and 13S6P pack arithmetic.
- Heuristic 48 V / 20 Ah pack sizing.
- Pack current/per-cell current conversion.
- Lower and upper SOC operating-window current limiting.
- Low-temperature 0.25C charging and charge inhibition.
- Database capacity/weight/dimension parsing.
- Regenerative current voltage-headroom, SOC and temperature limits.
- Passive shunt current calculation.

**MATLAB and GNU Octave were not available for execution during this audit. No test pass rate is claimed.** A file existing in the test folder is not proof that it passes. The dashboard UI is not covered by a headless automated UI test.

Run from the canonical `Battery_Model` folder:

```matlab
projectPaths = setupProject();
results = runAllTests();
disp(results);
```

Then launch:

```matlab
app = BMSDashboard();
R = app.GetResults();
```

Record MATLAB release, operating system, date, total test count, pass/fail/incomplete counts, warnings and UI issues.

## 7. Remaining engineering work

1. Confirm the exact NCR18650B part/datasheet revision and cell geometry configuration for the actual cell used.
2. Characterize R0/R1/C1 and optional R2/C2 over SOC and temperature; document the test procedure and fitting method.
3. Record OCV table source, temperature, rest duration, charge/discharge direction, SOC reference and processing steps.
4. Execute the complete MATLAB test suite; fix all failures and retain the execution output.
5. Execute every demonstration script individually; regenerate corrected dynamic result plots.
6. Execute `recommendPack` and `BatteryDesigner(48,20)` against the actual workbook. Inspect records, ranking and field semantics; document the workbook's source/date.
7. Launch the dashboard in the target MATLAB version and verify controls, plots, error handling and CSV export.
8. Validate the thermal model using measured cell-temperature data and timestep-convergence analysis.
9. Validate passive balancing resistor power/temperature and regenerative charge acceptance over SOC and temperature.
10. Compare model predictions against independent measured data and publish RMSE, MAE, maximum absolute error and operating conditions.
11. Add pack-level constraints for current, thermal limits, enclosure, busbar, cooling, fusing, cell mismatch and system requirements.
12. Develop a separate safety concept, hazard analysis and fault-response strategy before any hardware/safety claims.

## 8. Unsupported claims

Do not claim EKF SOC estimation, SOH/aging estimation, fault diagnosis, thermal-runaway prediction, experimentally measured SOC/voltage/thermal accuracy, quantified regenerative-energy recovery, quantified balancing improvement, official WLTP/UDDS validation, ISO 26262 compliance, safety certification or production readiness without additional source and reproducible evidence.

## 9. Reporting vocabulary

- **Implemented:** source code exists.
- **Unit-tested:** programmed assertions passed in a recorded execution.
- **Calibrated:** parameters fitted using traceable calibration data.
- **Independently validated:** predictions compared with separate measured data.
- **Safety-qualified:** formal safety engineering and applicable assessment evidence exists.

Never use these terms interchangeably.
