# Battery Management System — Execution Guide

This guide documents the current MATLAB implementation. It does not imply that planned EKF/UKF, hybrid SOH, balancing, fault diagnosis or integrated BMS features are already implemented.

## 1. Canonical source directory

Use this directory as the active MATLAB project:

Advanced Battery Management System for Electric or Hybrid Vehicles/Battery_Model/

Canonical folders:
- Parameters/ — cell initialization and OCV table loading.
- Cell_Library/ — Panasonic NCR18650B data and documentation.
- Cell_Model/ECM/ — first-order Thevenin equivalent-circuit model.
- Cell_Model/Thermal/ — lumped thermal model and Joule heat calculation.
- SOC/ — Coulomb-counting SOC update.
- Simulation/CurrentProfile/ — constant, step, pulse and illustrative drive-cycle profiles.
- BatteryPack/ — pack creation, design, validation and pack calculations.
- Pack_Database/ — commercial pack database import, cleaning and recommendation.
- Tests/ — existing runnable demonstration scripts.

A nested Battery_Model/Battery_Model/ directory contains duplicate copies of many files and additional generated/output material. Treat it as a legacy duplicate for now. Do not add it to the MATLAB path together with the canonical tree. It has not been deleted because its extra files have not yet been reconciled.

## 2. One-time MATLAB setup

1. Clone or download the repository.
2. Set the MATLAB Current Folder to the canonical Battery_Model directory.
3. Run:

    projectPaths = setupProject();

4. Confirm that the setup reports success and finds:
   Cell_Library/Panasonic_NCR18650B/Data/OCV_SOC.csv

The setup script adds only known source directories. It deliberately avoids genpath, which would also add the nested duplicate tree and can cause MATLAB to resolve duplicate function names unpredictably.

## 3. Recommended execution order

### Step 1 — Initialize cell parameters

Run:

    Battery = initBattery();

Function: Parameters/initBattery.m

This creates the Panasonic NCR18650B parameter structure and loads the static OCV-SOC table. Inspect:

    Battery.CellModel
    Battery.DesignCapacity
    Battery.NominalVoltage
    Battery.R0
    Battery.R1
    Battery.C1
    Battery.SOC_Table
    Battery.OCV_Table

The capacity field defined by the initializer is DesignCapacity (Ah). Do not use NominalCapacity; it is not defined by the initializer.

### Step 2 — Basic SOC demonstration

Run:

    run('Tests/testSOC.m')

Demonstrates one Coulomb-counting update. This is a demonstration script, not a full automated test suite.

### Step 3 — Static-current ECM demonstration

Run:

    run('Tests/testECM.m')

Simulates the 1RC ECM under constant 8 A discharge and plots terminal voltage, OCV and SOC.

### Step 4 — Dynamic-current ECM demonstration

Run:

    run('Tests/testDynamicECM.m')

Uses the illustrative drive-cycle current profile by default. The script contains alternative constant, step and pulse profiles; enable only one profile assignment at a time.

Current sign convention: positive current is discharge; negative current represents regenerative charging.

### Step 5 — Thermal demonstration

Run:

    run('Tests/testTemperature.m')

Simulates temperature rise under constant 20 A using the current Joule-heating and first-order lumped thermal model.

### Step 6 — Create and inspect a battery pack

Run:

    run('Tests/testBatteryPack.m')

Initializes a cell and creates an 80-series, 2-parallel pack.

### Step 7 — Pack calculations

Run:

    run('Tests/testPackAPI.m')

Demonstrates pack voltage, current, power and energy calculations for a 13S6P configuration.

### Step 8 — Custom pack design

Run:

    run('Tests/testDesignPack.m')

Calls designPack(48,20) and displays the design. The current design routine is a bounded heuristic search, not a validated global optimizer.

### Step 9 — Commercial pack database

Run:

    run('Tests/testPackDatabase.m')

Imports and cleans Pack_Database/Packdata.xlsx.

### Step 10 — Commercial pack recommendation

Run:

    run('Tests/testRecommendPack.m')

Ranks commercial database entries against a 48 V, 20 Ah target using the current weighted score.

### Step 11 — Combined battery design report

Run:

    Report = BatteryDesigner(48,20);

Compares a commercial recommendation with a custom pack design and calls the current pack validator.

## 4. Quick-start sequence

After setup, the following commands run the principal demonstrations:

    Battery = initBattery();
    run('Tests/testSOC.m');
    run('Tests/testECM.m');
    run('Tests/testDynamicECM.m');
    run('Tests/testTemperature.m');
    run('Tests/testBatteryPack.m');
    run('Tests/testPackAPI.m');
    run('Tests/testDesignPack.m');
    run('Tests/testPackDatabase.m');
    run('Tests/testRecommendPack.m');
    Report = BatteryDesigner(48,20);

Run individual scripts first when debugging. Some scripts clear the workspace and close figures, so variables from one script should not be expected to remain available to the next.

## 5. Script classification

| File | Purpose | Current status |
|---|---|---|
| Parameters/initBattery.m | Canonical cell-parameter initializer and OCV data loader | Existing function |
| Cell_Library/Panasonic_NCR18650B/Scripts/configureReferencePack.m | Configure a reference 80S1P pack using the canonical initializer | Legacy pack-configuration script, renamed to avoid initializer ambiguity |
| runAllTests.m | Run the automated unit-test suite | New test runner |
| SOC/coulombCounting.m | SOC by Coulomb counting | Existing function |
| Cell_Model/ECM/batteryECM.m | 1RC ECM voltage prediction | Existing function |
| Cell_Model/Thermal/updateTemperature.m | Lumped thermal update | Existing function |
| Tests/testECM.m | Constant-current ECM demo | Demo script |
| Tests/testDynamicECM.m | Dynamic-current ECM demo | Demo script |
| Tests/testTemperature.m | Thermal demo | Demo script |
| Tests/testBatteryPack.m | Pack construction demo | Demo script |
| Tests/testDesignPack.m | Custom design demo | Demo script |
| Tests/testPackAPI.m | Pack calculation demo | Demo script |
| Tests/testPackDatabase.m | Database import demo | Demo script |
| Tests/testRecommendPack.m | Commercial recommendation demo | Demo script |
| Tests/testBatteryDesigner.m | Combined design report demo | Demo script |

The current Tests scripts mostly execute code and display results. They are not yet a comprehensive matlab.unittest regression suite.

## 6. Known limitations before research-grade use

- The current estimator is Coulomb counting only; EKF/UKF are not implemented.
- The current ECM is a 1RC model with fixed parameters.
- The OCV lookup currently extrapolates outside its SOC data range.
- The ECM function clips terminal voltage to cell limits, which can hide violations.
- The thermal model currently uses irreversible Joule heat only.
- SOH estimation, balancing control and fault-diagnosis logic are not implemented.
- Pack design and commercial recommendation use heuristic weighted scores and need explicit engineering constraints and sensitivity analysis.
- No integrated .slx model was confirmed in the tracked source tree during this audit. A .slxc file is a Simulink cache artifact, not the editable model.
- MATLAB/Simulink runtime tests have not been executed by this documentation change.

## 7. Troubleshooting

**initBattery not found:** Confirm that the Current Folder is the canonical Battery_Model directory and run setupProject().

**OCV CSV not found:** Confirm that Cell_Library/Panasonic_NCR18650B/Data/OCV_SOC.csv exists.

**Wrong function version executes:** Run which initBattery -all or which batteryECM -all. Remove the nested legacy duplicate directory from the MATLAB path.

**Excel import fails:** Confirm Pack_Database/Packdata.xlsx is present and your MATLAB installation supports readtable.

## 8. Research implementation roadmap

1. Stabilize parameter naming, model input validation and pack API.
2. Convert demonstrations into assertion-based automated tests.
3. Establish public battery dataset provenance and preprocessing.
4. Implement and compare SOC estimators.
5. Implement hybrid SOH estimation with independent validation data.
6. Add cell-level balancing and quantify balancing energy/time.
7. Add fault detection, fault isolation where supported, and safe response logic.
8. Integrate the plant and supervisory BMS in Simulink.
9. Run reproducible experiments and report accuracy, safety, efficiency and computational cost.

Do not describe planned features as completed until implementation and validation evidence exist.
