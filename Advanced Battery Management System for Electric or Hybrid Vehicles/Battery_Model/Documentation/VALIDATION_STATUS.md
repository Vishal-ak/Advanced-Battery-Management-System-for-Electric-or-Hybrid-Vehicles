# Validation Status and Limitations

**Status date:** 14 November 2026  
**Scope:** MATLAB source tree in this repository branch.

This register distinguishes implemented code, automated software tests and engineering validation. These are different levels of evidence.

## 1. Implementation inventory

| Area | Present in source tree | Current evidence level |
|---|---|---|
| Reference-cell initialization and OCV lookup | Yes | Code-level; data provenance and parameter accuracy need review |
| 1RC Thevenin ECM | Yes | Unit and demonstration tests exist; independent model validation not established |
| 2RC Thevenin ECM | Yes | Helper functions restored and regression tests added; MATLAB Online execution reported 30 total suite tests passing; parameters remain preliminary |
| Coulomb-counting SOC | Yes | Unit and demonstration tests exist; drift and accuracy need measured validation |
| EKF SOC estimator | No | Not implemented in the tracked source tree |
| Lumped thermal model | Yes | Unit and demonstration tests exist; calibration against temperature measurements is not established |
| SOH / aging estimator | No | Not implemented in the tracked source tree |
| Pack creation and sizing | Yes | Code and demonstration tests exist; design heuristic and hardware assumptions need engineering review |
| Commercial pack database and recommendation | Yes | Data processing and demonstration tests exist; source provenance and completeness should be documented |
| Passive balancing | Yes | Simplified logic and regression test; no hardware or thermal validation |
| Regenerative-braking current limit | Yes | Simplified supervisory estimate and regression test; no cell charge-acceptance validation |
| Safety-qualified BMS / ISO 26262 implementation | No | No safety case, hazard analysis or compliance evidence |
| Integrated Simulink model | No | No tracked `.slx` file |

## 2. Automated tests

The repository includes a MATLAB test runner at `runAllTests.m` and automated tests under `Tests/Automated_Test_File`.

Run the suite from the canonical `Battery_Model` directory:

```matlab
projectPaths = setupProject();
results = runAllTests();
```

Record the MATLAB release, date, test count, passed/failed/incomplete counts and any warnings when publishing a test result.

**Important:** A test file being present does not prove that it has been executed. Do not report the suite as passing until the actual MATLAB output has been reviewed. The user reported a MATLAB Online run with 30 tests passed, 0 failed and 0 incomplete (10 2RC, 4 advanced modules, 6 ECM, 6 SOC and 4 thermal tests). This run predates the dashboard and shared figure-export integration; rerun the suite after those changes. The current development environment has no MATLAB or GNU Octave runtime, so the new dashboard has not been executed here. Unit tests check programmed assertions; they do not demonstrate model agreement with physical cells.

## 3. Engineering assumptions requiring evidence

### Reference-cell audit — Panasonic NCR18650B
The parameter initializer on this branch now records the following manufacturer specifications from Panasonic NCR18650B datasheet, Version 13.11 R1 (2012):
- Nominal voltage: 3.6 V.
- Rated capacity: minimum 3.20 Ah at 20°C.
- Capacity at 25°C: minimum 3.25 Ah; typical 3.35 Ah.
- Standard charge current: 1.625 A; charge voltage: 4.20 V.
- Maximum cell mass: 48.5 g; maximum bare-cell dimensions: 18.25 mm diameter × 65.10 mm height.
- Discharge temperature range: −20°C to +60°C; charge temperature range: 0°C to +45°C.

The project uses typical 3.35 Ah as its design capacity. Rated, minimum and typical capacity are retained as separate fields; they must not be interchanged. The nominal voltage and standard charge current were corrected from 3.7 V and 1.65 A to 3.6 V and 1.625 A.

Still provisional / not manufacturer-verified:
- Fixed internal resistance and ECM parameters (R0, R1, C1, R2, C2).
- Maximum discharge current configured in the project (5 A).
- Specific heat and lumped thermal resistance.
- OCV_SOC.csv: source, cell lot, test temperature, rest duration, charge/discharge direction and SOC calibration are not documented. The table is therefore marked unverified and must not be described as Panasonic-supplied or experimentally validated. A potentially relevant public dataset is Rüther et al., “Cell-to-Cell-Variations of a Panasonic NCR18650B” (Zenodo DOI 10.5281/zenodo.8369275): it contains 92-cell characterization at 25°C and pseudo-OCV charge/discharge measurements at 0.05C, interpolated to 5000 equidistant SOC points. The repository CSV also has 5000 rows, but row count alone does not establish that it was derived from this dataset. Its values must be compared against the published files before attributing provenance.

Datasheet reference: Panasonic NCR18650B, Version 13.11 R1 (2012), reproduced at https://e2e.ti.com/cfs-file/__key/communityserver-discussions-components-files/196/Panasonic-NCR18650B-datasheet.pdf. This is a third-party-hosted copy of the manufacturer document; retain the revision identifier when citing it.

Internal resistance varies with SOC, temperature, age and measurement method; a single fixed value is an approximation. Do not invent or infer provenance for the OCV lookup table.
## 4. Claims that must not be made without additional evidence

Do not claim any of the following on the basis of the current repository alone:

- A measured 3.8× improvement in EKF SOC accuracy.
- A measured 14.1% regenerative-energy recovery.
- A demonstrated reduction in cell-voltage spread to a stated value.
- Experimental validation across a named driving cycle unless the exact trace, test conditions and reproducible results are included.
- ISO 26262 compliance, safety certification or production readiness.
- Validated SOH estimation, fault diagnosis or thermal-runaway prediction.

If such experiments are completed later, add raw or traceable source data, scripts, test configuration, metrics, plots and a clear distinction between calibration and independent validation.

## 5. Recommended validation plan

1. Freeze and document the reference-cell parameter set and data provenance.
2. Identify 1RC and 2RC parameters using pulse tests at multiple SOC and temperatures.
3. Validate terminal-voltage prediction on independent dynamic profiles; report RMSE, MAE and maximum absolute error.
4. Compare Coulomb-counting SOC against a trusted reference measurement and quantify drift.
5. Validate the thermal model against measured cell-temperature data under multiple current profiles.
6. Test pack scaling, current limits, mass and energy calculations with independent hand calculations.
7. Validate balancing and regenerative-braking logic against component ratings and cell charge-acceptance constraints.
8. Add automated regression tests for every corrected defect and repeat the full suite after changes.

## 6. Reporting rule

Use precise status language:

- **Implemented:** source code exists.
- **Unit-tested:** the corresponding automated assertions passed in a recorded MATLAB run.
- **Calibrated:** parameters were fitted to identified calibration data.
- **Independently validated:** performance was evaluated on separate measured data.
- **Safety-qualified:** formal safety engineering and applicable assessment evidence exist.

Do not use these terms interchangeably.
