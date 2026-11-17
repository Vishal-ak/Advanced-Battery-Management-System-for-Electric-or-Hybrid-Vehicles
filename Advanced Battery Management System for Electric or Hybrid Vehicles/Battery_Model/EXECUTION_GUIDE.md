# MATLAB Execution Guide

## 1. Setup

Set MATLAB Current Folder to this canonical `Battery_Model` directory. Run:

```matlab
projectPaths = setupProject();
Battery = initBattery();

which initBattery -all
which batteryECM -all
```

Confirm the resolved functions point into this Battery_Model tree. The setup deliberately excludes a legacy nested duplicate to avoid path shadowing.

## 2. Automated unit tests

```matlab
results = runAllTests();
disp(table(results));
```

The automated suite currently exercises selected ECM, SOC, thermal, 2RC, passive-balancing and regenerative-current assertions. Record the MATLAB release, date, number of tests and passed/failed/incomplete totals. Do not infer test success from the existence of test files.

## 3. Demonstration scripts

Run each script individually from this directory:

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

Some scripts clear the command window, workspace and figures. Run them separately, not as one combined script.

## 4. Core workflow examples

### Cell and ECM

```matlab
Battery = initBattery();
SOC = 0.70;
I = 2.0;       % A, positive means discharge
dt = 1.0;      % s
Vrc = 0;

[Vt,Vrc,OCV,Status] = batteryECM(SOC,I,Vrc,dt,Battery);
disp(Status)
```

### Coulomb-counting SOC

```matlab
SOC0 = 0.70;
SOC1 = coulombCounting(SOC0,2.0,60,Battery.DesignCapacity);
```

This is current integration only. The OCV table is used in ECM voltage prediction; no rest-based OCV correction or EKF is claimed in the core workflow.

### 2RC model

```matlab
[Vt,Vrc1,Vrc2,OCV,Status] = batteryECM_2RC( ...
    0.70,2.0,0,0,1,Battery);
```

The second polarization branch parameters are preliminary. Calibrate them before treating this model as predictive.

### Pack design

```matlab
Pack = createBatteryPack(Battery,13,6,false);
Validation = validatePack(Pack);

% Supply application-specific limits rather than assuming universal limits
Req.MaxPackVoltage_V = 60;
Req.MaxPackMass_kg = 10;
Req.MaxCellCount = 100;
Req.MinCapacity_Ah = 20;
Validation = validatePack(Pack,Req);
```

The example limits are illustrative only and are not safety recommendations.

## 5. Known issues / caution

- `initCell.m` under the cell-library Scripts folder is a legacy script and refers to a `Battery.NominalCapacity` field that is not defined by the current initializer. Prefer `initBattery()` and the canonical pack functions.
- The older reference-pack scripts contain provisional ECM values that disagree with `initBattery.m`. Do not use them as the active parameter source.
- `BatteryDesigner` currently has a schema mismatch between the commercial recommendation table and fields expected by its formatted report. Do not rely on this end-to-end pathway until corrected and tested.
- Commercial database score normalization can divide by zero or propagate invalid values for some datasets.
- Low-level utility functions are not yet uniformly validated for malformed/non-finite inputs.
- The thermal model is single-node and its Euler update needs timestep-convergence checks.
- Pack mass includes estimates, cell-only volume and cell-only cost have limited scope.
- No production protection, safety qualification, ISO 26262 compliance or hardware validation is provided.

## 6. Reporting test results

Use the actual MATLAB test-run output. Report the MATLAB version, operating system, test date, number of tests, pass/fail/incomplete counts and any test diagnostics. Do not put an unexecuted or hypothetical result in the project report.
