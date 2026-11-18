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
- Synthetic drive-cycle, constant-discharge, constant-charge, step and pulse current profiles with pack-to-cell current scaling.
- Series-parallel pack construction and bounded heuristic pack sizing.
- Pack voltage, current, power and nominal-energy utilities with validated scalar inputs.
- Commercial pack database loading, cleaning and recommendation.
- Simplified passive cell-balancing logic.
- Simplified regenerative-braking charge-current limit.
- Pack consistency checks, expanded MATLAB automated tests, and a pack-scaled simulation service.
- Interactive MATLAB simulation dashboard with current, voltage, SOC and temperature plots plus CSV export.

The SOC workflow currently supported by the tracked core is **Coulomb counting with an OCV–SOC lookup for the ECM voltage model**. The OCV lookup does not correct SOC from rested voltage. An EKF/SOH estimator is not part of the verified core source inventory.

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
results = runAllTests();

% Launch the interactive simulation dashboard
app = BMSDashboard();
```

See [Execution Guide](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/EXECUTION_GUIDE.md) for individual demonstrations and execution order.

## Documentation

- [Execution guide](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/EXECUTION_GUIDE.md).
- [Reference-cell specification](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/Cell_Library/Panasonic_NCR18650B/Documentation/Cell%20Specification.md).

## Reference pack arithmetic

For an illustrative 13S6P configuration using the Panasonic NCR18650B nominal voltage of 3.6 V:

```matlab
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);

Pack.NominalVoltage
Pack.MaximumVoltage
Pack.CutoffVoltage
Pack.Capacity
Pack.Energy_Wh
Pack.Mass
```

Ideal arithmetic gives 46.8 V nominal, 54.6 V maximum, 32.5 V cutoff and 20.1 Ah. Nominal energy is 940.68 Wh. A 13S6P pack is therefore a 48-V-class configuration, not 48.1 V nominal when using the NCR18650B's 3.6 V nominal rating.

The pack's standard-charge-current calculation is 9.75 A for six parallel cells (6 × 1.625 A), assuming ideal current sharing. The configured 5 A per-cell discharge limit is a conservative project model limit, not a maximum discharge rating stated by the referenced datasheet.

These are calculated model outputs, not measured pack performance. Mass includes configured pack-level hardware allowances; volume is based on cell-envelope geometry; estimated cost is cell-only.

## Evidence and reporting

A script, plot or test file in the repository is not proof it was executed successfully. Record MATLAB release, date, test counts and pass/fail status from an actual run.

Passing unit tests verifies programmed assertions only. It does not prove agreement with physical cells, correct parameter identification, battery safety or vehicle-level performance. Distinguish implemented, unit-tested, calibrated, independently validated and safety-qualified.

Do not report simulation outputs as experimental results. Do not claim ISO 26262 compliance, production readiness, EKF accuracy improvements, regenerative-energy recovery percentages or balancing improvements without reproducible evidence.

## License and use

This repository is intended for education and research. Confirm operating limits against the applicable manufacturer documentation and system requirements before using model outputs to guide real hardware.
