# MATLAB Execution Guide

This guide applies to the canonical `Battery_Model` directory.

## 1. Open and configure the project

In MATLAB Online or MATLAB Desktop, set the Current Folder to this directory. Then run:

```matlab
projectPaths = setupProject();
Battery = initBattery();

which initBattery -all
which batteryECM -all
which updateRCVoltage -all
```

Confirm that MATLAB resolves each function to the intended project path. Avoid adding every nested directory with `genpath` when duplicate or legacy folders may exist.

## 2. Run automated tests

```matlab
results = runAllTests();
```

The automated tests are located in `Tests/Automated_Test_File`. Review the test summary and any failed or incomplete tests. A passing unit-test suite is not equivalent to experimental model validation, hardware qualification or functional-safety certification.

## 3. Initialize and inspect the reference cell

```matlab
Battery = initBattery();
disp(Battery)
```

The initialized structure contains the reference-cell electrical, thermal and physical parameters and the OCV–SOC lookup data used by the models. Check the parameter source and units before changing values.

## 4. Run demonstrations

Run scripts individually from the `Battery_Model` folder:

```matlab
run('Tests/testSOC.m')
run('Tests/testECM.m')
run('Tests/testDynamicECM.m')
run('Tests/testTemperature.m')
run('Tests/testBatteryPack.m')
run('Tests/testPackAPI.m')
run('Tests/testDesignPack.m')
run('Tests/testPackDatabase.m')
run('Tests/testRecommendPack.m')
run('Tests/testBatteryDesigner.m')
```

Some demonstration scripts clear the workspace, create figures or print extensive console output. Run them one at a time and save any required plots or results deliberately.

## 5. Construct and inspect a pack

```matlab
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);

Pack.Configuration
Pack.NominalVoltage
Pack.MaximumVoltage
Pack.CutoffVoltage
Pack.Capacity
Pack.Energy_Wh
Pack.Mass
```

The pack mass combines cell mass with configured pack-level BMS, enclosure, busbar and wiring allowances. These allowances are estimates. The cost estimate in the design routine is cell-only. Cell-envelope volume is not complete pack volume.

## 6. Design and validate a pack

```matlab
Pack = designPack(48,20);

Requirements.MaxPackVoltage_V = 60;
Requirements.MaxPackMass_kg = 5.0;
Requirements.MaxCellCount = 100;
Requirements.MinCapacity_Ah = 20;
Requirements.MinDischargeCurrent_A = 25;
Requirements.MinTemperature_C = -10;
Requirements.MaxTemperature_C = 55;

Validation = validatePack(Pack,Requirements);
```

The requirement values above are illustrative only. Replace them with system-level requirements for the intended application. If a requirement is not supplied, the validator does not invent a universal limit.

## 7. Run ECM predictions

First-order model:

```matlab
[Vt,Vrc,OCV,Status] = batteryECM(SOC,Current,VrcOld,dt,Battery);
```

Second-order model:

```matlab
[Vt,Vrc1,Vrc2,OCV,Status] = batteryECM_2RC( ...
    SOC,Current,Vrc1Old,Vrc2Old,dt,Battery);
```

The current convention is positive for discharge and negative for charge. The predicted terminal voltage is not clipped to the cell voltage limits. Inspect `Status.OverVoltage`, `Status.UnderVoltage` and `Status.WithinVoltageLimits`. These flags report a condition; they do not operate contactors or implement a complete protection system.

The OCV interpolation currently extrapolates outside the lookup-table SOC range. Keep SOC within the characterized range and validate the lookup data before relying on predictions near the endpoints.

## 8. Current-profile functions

The `Simulation/CurrentProfile` folder contains:

- `constantCurrent` — constant current input.
- `stepCurrent` — step changes in current.
- `pulseCurrent` — pulse-load profile.
- `driveCycleCurrent` — current profile derived from a supplied speed/drive-cycle input.

Positive current denotes discharge; negative current denotes charging. Check each function's argument list and units in its MATLAB help text before calling it.

## 9. Known limitations

- The cell model uses fixed parameters; parameter identification versus SOC, temperature and SOH is not implemented as a validated workflow.
- The 2RC branch values are preliminary.
- The thermal model is lumped and simplified.
- SOC estimation currently includes Coulomb counting; a validated EKF implementation is not present in the tracked source tree.
- A validated SOH estimator, fault-diagnosis system and production protection controller are not present in the tracked source tree.
- Balancing and regenerative-braking functions are simplified demonstrations.
- Pack design is a bounded heuristic, not a global optimization.
- Hardware mass allowances and cell-only cost assumptions need sourced values.
- No integrated Simulink `.slx` model is tracked.

For the evidence status and limitations of each module, see [Documentation/VALIDATION_STATUS.md](Documentation/VALIDATION_STATUS.md).
