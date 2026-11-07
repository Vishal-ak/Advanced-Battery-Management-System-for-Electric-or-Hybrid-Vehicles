# Battery Management System — MATLAB Project

This folder is the canonical MATLAB source tree for the EV/HEV battery modelling project.

## Quick start

From this folder in MATLAB:

```matlab
projectPaths = setupProject();
Battery = initBattery();
results = runAllTests();
```

Run demonstrations individually using the sequence in [EXECUTION_GUIDE.md](EXECUTION_GUIDE.md).

## Main modules

| Folder | Responsibility |
|---|---|
| Parameters | Panasonic NCR18650B cell parameters and data loading |
| Cell_Library | Cell datasets and reference documentation |
| Cell_Model/ECM | First-order and optional second-order Thevenin ECM |
| Cell_Model/Thermal | Lumped thermal model and thermal-management controller |
| Cell_Model/Aging | Preliminary SOH/aging estimator |
| SOC | Coulomb counting and EKF SOC estimation |
| Simulation | Drive-cycle, regenerative-braking and telemetry functions |
| BatteryPack | Pack sizing, balancing and protection logic |
| Pack_Database | Commercial pack data and recommendation |
| Tests | Demonstrations and automated unit tests |

## Engineering limitations

- ECM voltage outputs are physical model predictions and are not clipped. Check the returned status and implement protective action in a supervisory BMS.
- 2RC parameters and aging-model coefficients are preliminary; identify and validate them against traceable cell test data before making performance claims.
- Passive balancing and regenerative-braking logic are simplified supervisory demonstrations, not hardware-qualified controls.
- Pack mass includes cell mass plus configured pack-level BMS, enclosure, busbar and wiring estimates. Replace these estimates with sourced or measured values.
- Reported volumetric density is based on summed cell-envelope volume; complete-pack volume requires enclosure and hardware geometry.
- Current pack cost is cell-only and excludes BMS, enclosure, assembly, interconnects and testing.
- Pack design is a bounded heuristic, not a globally optimal design.
- No editable integrated Simulink `.slx` model is included in this source tree.
- MATLAB runtime tests must be executed in MATLAB; code review is not evidence that the tests pass.

Do not describe planned or simplified demonstration features as production-ready BMS functionality.
