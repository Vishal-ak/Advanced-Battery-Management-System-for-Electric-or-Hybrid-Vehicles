# Validation Status and Limitations

**Status date:** 7 November 2026  
**Scope:** MATLAB source tree in this repository branch.

This register distinguishes implemented code, automated software tests and engineering validation. These are different levels of evidence.

## 1. Implementation inventory

| Area | Present in source tree | Current evidence level |
|---|---|---|
| Reference-cell initialization and OCV lookup | Yes | Code-level; data provenance and parameter accuracy need review |
| 1RC Thevenin ECM | Yes | Unit and demonstration tests exist; independent model validation not established |
| 2RC Thevenin ECM | Yes | Optional implementation; added branch parameters are preliminary |
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

**Important:** A test file being present does not prove that it has been executed. Do not report the suite as passing until the actual MATLAB output has been reviewed. Unit tests check programmed assertions; they do not demonstrate model agreement with physical cells.

## 3. Engineering assumptions requiring evidence

### Cell data and parameters
- Confirm each parameter against the exact Panasonic datasheet revision or a traceable test.
- Record whether capacity is typical, rated or minimum and under what test conditions.
- Internal resistance varies with SOC, temperature, age and measurement method; a single fixed value is an approximation.
- Verify the OCV–SOC CSV provenance, test temperature, rest duration, charge/discharge direction and SOC calibration.

### ECM
- Identify (R_0), (R_1), (C_1), (R_2) and (C_2) from cell pulse or dynamic test data.
- Validate voltage prediction on data not used for parameter fitting.
- Quantify error across SOC, temperature, current and cell age.
- Confirm sign conventions and numerical stability.

### Thermal model
- Validate heat-generation terms and thermal parameters against measured temperature traces.
- A single-node model cannot resolve internal gradients or predict thermal runaway propagation.

### Pack design
- Replace hardware mass allowances with sourced or measured component masses.
- Distinguish cell-only cost from complete-pack cost.
- Distinguish cell-envelope volume from complete pack volume.
- Validate current limits against cell parallel count, interconnects, fusing, cooling and operating conditions.
- Treat the pack-design score as a heuristic ranking, not a global optimum.

### Balancing and regenerative braking
- Validate balancing thresholds, resistor power, component temperature and energy loss.
- Validate regenerative charge-current limits against manufacturer charge limits and measured charge-acceptance data over SOC and temperature.
- Neither function is suitable as a standalone hardware control policy.

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
