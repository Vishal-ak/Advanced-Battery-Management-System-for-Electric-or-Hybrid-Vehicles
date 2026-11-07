# Battery Model — MATLAB Project

This is the canonical MATLAB source directory. Open this folder as the MATLAB Current Folder before running project scripts.

## Start here

```matlab
projectPaths = setupProject();
Battery = initBattery();
results = runAllTests();
```

If the tests are run, inspect the returned `results` array and MATLAB test summary. Do not assume a successful setup or battery initialization means the complete test suite has passed.

## Documentation

| Document | Purpose |
|---|---|
| [Execution guide](EXECUTION_GUIDE.md) | Setup, examples, tests and run order |
| [Model reference](Documentation/MODEL_REFERENCE.md) | Implemented model equations, conventions and assumptions |
| [Validation status](Documentation/VALIDATION_STATUS.md) | Test scope, evidence requirements and known limitations |
| [Cell specification](Cell_Library/Panasonic_NCR18650B/Documentation/Cell%20Specification.md) | Reference-cell summary |
| [Manufacturer datasheets](Cell_Library/Panasonic_NCR18650B/Datasheet/) | Source documents for cell limits and characteristics |

## Module map

| Directory | Implemented responsibility |
|---|---|
| `Parameters` | Initialize reference-cell parameters and load OCV–SOC data |
| `Cell_Library` | Cell reference data, datasheets and cell setup utilities |
| `Cell_Model/ECM` | 1RC and optional 2RC Thevenin voltage models |
| `Cell_Model/Thermal` | Heat-generation and lumped-temperature calculations |
| `SOC` | Coulomb-counting SOC update |
| `Simulation/CurrentProfile` | Constant, step, pulse and drive-cycle current profiles |
| `Simulation` | Simplified regenerative-braking current-limit calculation |
| `BatteryPack` | Pack creation, sizing, electrical API, balancing demonstration and validation |
| `Pack_Database` | Commercial pack database processing and recommendation |
| `Tests` | Demonstration scripts and automated unit tests |

## Important boundaries

This is not a production BMS. The ECM and thermal models are simplified; 2RC parameters and hardware mass allowances need validation. The pack-sizing routine is a bounded heuristic. Passive balancing and regenerative-braking functions are demonstrations, not hardware-qualified controllers. There is no integrated Simulink model or validated EKF/SOH implementation in the tracked source tree.

See [Validation Status](Documentation/VALIDATION_STATUS.md) before using project results in a report or presentation.
