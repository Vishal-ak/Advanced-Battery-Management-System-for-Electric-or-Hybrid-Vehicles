# Advanced Battery Management System for Electric and Hybrid Vehicles

A MATLAB-based educational engineering project for modelling a lithium-ion cell, constructing series-parallel battery packs, simulating electrical and thermal response, estimating state of charge, and evaluating pack configurations.

The tracked implementation is organized around the **Panasonic NCR18650B** reference cell. Cell data, model assumptions and manufacturer reference documents are maintained separately from the simulation code.

> **Status:** Substantial model and pack-design functionality is present. This is not a production-qualified or safety-certified BMS. Runtime tests and experimental validation must be performed before quantitative performance or safety claims are made.

## Implemented scope

- Reference-cell parameter initialization and tabulated OCV–SOC lookup.
- First-order Thevenin equivalent-circuit model (1RC).
- Optional second-order Thevenin equivalent-circuit model (2RC).
- Coulomb-counting SOC update.
- Lumped single-node thermal model and ohmic heat-generation calculation.
- Constant, step, pulse and synthetic drive-cycle current profiles.
- Series-parallel pack construction and bounded heuristic pack sizing.
- Pack voltage, current, power and nominal-energy utilities.
- Commercial pack database loading, cleaning and recommendation.
- Simplified passive cell-balancing logic.
- Simplified regenerative-braking charge-current limit.
- Pack consistency checks and MATLAB automated tests.

The SOC workflow currently supported by the tracked core is **Coulomb counting with OCV–SOC lookup for the ECM voltage model**. An EKF/SOH implementation is not part of the verified core source inventory. Do not claim EKF SOC estimation, SOH estimation, fault diagnosis, safety-qualified protection, or an integrated Simulink model as delivered functionality unless corresponding code and validation evidence are added.

## Repository layout

```text
.
├── README.md
├── LICENSE
├── diagram.png
└── Advanced Battery Management System for Electric or Hybrid Vehicles/
    └── Battery_Model/
        ├── BatteryPack/       Pack design, API, balancing and validation
        ├── Cell_Library/      Reference-cell data and datasheets
        ├── Cell_Model/        ECM and thermal models
        ├── Documentation/     Model reference and validation register
        ├── Pack_Database/     Commercial pack data and recommendation
        ├── Parameters/        Cell parameter initialization
        ├── SOC/               Coulomb-counting SOC
        ├── Simulation/        Current profiles and regen demonstration
        ├── Tests/             Demonstrations and automated tests
        ├── setupProject.m
        ├── runAllTests.m
        └── EXECUTION_GUIDE.md
```

## Quick start

Set MATLAB Current Folder to the canonical `Battery_Model` directory, then run:

```matlab
projectPaths = setupProject();
Battery = initBattery();

% Execute the automated suite and inspect the returned test results
results = runAllTests();
```

See [Execution Guide](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/EXECUTION_GUIDE.md) for individual demonstrations and execution order.

## Documentation

- [Execution guide](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/EXECUTION_GUIDE.md) — setup, tests and demonstration scripts.
- [Model reference](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/Documentation/MODEL_REFERENCE.md) — equations, conventions and modelling assumptions.
- [Validation status](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/Documentation/VALIDATION_STATUS.md) — implementation inventory, known defects and evidence needed.
- [Reference-cell specification](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/Cell_Library/Panasonic_NCR18650B/Documentation/Cell%20Specification.md).

## Reference pack calculation

For an illustrative 13S6P configuration:

```matlab
Battery = initBattery();
Pack = createBatteryPack(Battery, 13, 6, false);

Pack.NominalVoltage
Pack.MaximumVoltage
Pack.CutoffVoltage
Pack.Capacity
Pack.Energy_Wh
Pack.Mass
```

With the current runtime initialization (3.70 V nominal, 4.20 V maximum, 2.50 V cutoff, 3.35 Ah design capacity), ideal arithmetic gives 48.10 V nominal, 54.60 V maximum, 32.50 V cutoff and 20.10 Ah. Energy is 966.81 Wh. These are calculated model outputs, not measured pack performance. The current mass includes configurable pack-level hardware allowances; the volume estimate is cell-envelope-only; the cost estimate is cell-only.

## Evidence and reporting

A script, plot, or test file in the repository is not proof that it was executed successfully. Record the MATLAB release, date, test counts and pass/fail status from an actual run.

Passing unit tests verifies programmed assertions only. It does not prove agreement with physical cells, correct parameter identification, battery safety, or vehicle-level performance. Distinguish:

- **Implemented:** source code exists.
- **Unit-tested:** assertions passed in a recorded run.
- **Calibrated:** parameters fitted to traceable calibration data.
- **Independently validated:** tested on separate measured data.
- **Safety-qualified:** formal safety engineering and applicable assessment evidence exist.

Do not report simulation outputs as experimental results. Do not claim ISO 26262 compliance, production readiness, EKF accuracy improvements, regenerative-energy recovery percentages, or voltage-spread improvements without reproducible evidence.

## License and use

This repository is intended for education and research. Confirm operating limits against the applicable manufacturer documentation and system requirements before using model outputs to guide real hardware.
