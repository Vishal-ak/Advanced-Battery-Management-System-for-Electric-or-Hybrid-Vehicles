# Advanced Battery Management System for Electric and Hybrid Vehicles

A MATLAB-based educational and engineering project for modelling a lithium-ion cell, constructing series-parallel battery packs, simulating electrical and thermal response, estimating state of charge, and evaluating pack configurations.

The reference cell is the **Panasonic NCR18650B**. Cell data, model assumptions and manufacturer reference documents are maintained separately from the simulation code.

> **Project status:** This is a research and learning platform, not a production-qualified BMS. Model parameters and supervisory functions require calibration, independent validation and hardware testing before safety-critical use.

## What is implemented

- Reference-cell parameter initialization and OCV–SOC data loading.
- First-order Thevenin equivalent-circuit model (1RC).
- Optional second-order Thevenin model (2RC); its added branch parameters are preliminary.
- Coulomb-counting SOC update.
- Lumped cell thermal model and heat-generation calculation.
- Constant, step, pulse and drive-cycle current profiles.
- Series-parallel pack construction and bounded heuristic pack sizing.
- Pack-level voltage, current, power and energy utilities.
- Commercial pack database loading and recommendation.
- Simplified passive cell-balancing and regenerative-braking demonstrations.
- Pack consistency checks and MATLAB automated tests.

The repository does **not** currently contain an integrated Simulink `.slx` model, a validated EKF/SOH estimator, or a safety-certified BMS implementation.

## Repository layout

```text
.
└── Advanced Battery Management System for Electric or Hybrid Vehicles/
    └── Battery_Model/
        ├── BatteryPack/       Pack design, API, balancing and validation
        ├── Cell_Library/      Reference-cell data and datasheets
        ├── Cell_Model/        ECM and thermal models
        ├── Parameters/        Cell parameter initialization
        ├── Pack_Database/     Commercial pack data and recommendation
        ├── SOC/               Coulomb-counting SOC
        ├── Simulation/         Current profiles and regen demonstration
        ├── Tests/             Demonstrations and automated unit tests
        ├── Documentation/     Model reference and validation status
        ├── setupProject.m
        ├── runAllTests.m
        └── EXECUTION_GUIDE.md
```

## Quick start

Open the canonical `Battery_Model` folder in MATLAB Online or MATLAB Desktop:

```matlab
projectPaths = setupProject();
Battery = initBattery();

% Run the automated unit-test suite
results = runAllTests();
```

For examples and the correct order of execution, see [Execution Guide](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/EXECUTION_GUIDE.md).

## Documentation

- [Model reference](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/Documentation/MODEL_REFERENCE.md) — equations, sign conventions, model boundaries and assumptions.
- [Validation status](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/Documentation/VALIDATION_STATUS.md) — what is tested, what remains unverified and known limitations.
- [Reference-cell specification](Advanced%20Battery%20Management%20System%20for%20Electric%20or%20Hybrid%20Vehicles/Battery_Model/Cell_Library/Panasonic_NCR18650B/Documentation/Cell%20Specification.md).
- Manufacturer datasheets are stored in `Cell_Library/Panasonic_NCR18650B/Datasheet/`.

## Reference pack example

A 13-series, 6-parallel configuration using the initialized reference cell gives 78 cells. The theoretical pack values are calculated from the cell parameters:

```matlab
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);

Pack.NominalVoltage
Pack.MaximumVoltage
Pack.Capacity
Pack.Energy_Wh
Pack.Mass
```

Pack mass includes the configured hardware-mass allowances. These are estimates, not measured pack mass. The current cost estimate is cell-only. Volumetric energy density uses summed cell-envelope volume, not the complete enclosure volume.

## Reproducibility and claims

Run `results = runAllTests();` in MATLAB and retain the actual test summary when reporting test status. Passing unit tests verifies only the assertions in the suite; it does not establish agreement with laboratory measurements, safety compliance or vehicle-level performance.

Do not report simulated outputs as experimental results unless the experiment, source data, configuration and analysis are reproducible and documented.

## License and use

This repository is intended for educational and research use. Verify cell limits against the applicable manufacturer documentation and system requirements before using any model output to guide real hardware.
