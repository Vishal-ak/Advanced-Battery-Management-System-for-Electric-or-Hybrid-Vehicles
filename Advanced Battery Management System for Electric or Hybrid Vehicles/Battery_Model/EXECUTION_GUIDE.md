# Battery Management System — Execution Guide

This guide describes the currently tracked MATLAB implementation. Planned or simplified features must not be represented as validated production BMS functions.

## 1. Configure MATLAB

Set the Current Folder to the canonical `Battery_Model` directory, then run:

```matlab
projectPaths = setupProject();
Battery = initBattery();
which initBattery -all
which batteryECM -all
```

Do not use `genpath` across the repository if duplicate or legacy folders exist; explicit paths reduce function shadowing.

## 2. Automated tests

```matlab
results = runAllTests();
```

The automated suite checks the assertions present in `Tests/Automated_Test_File`. A passing result does not constitute hardware qualification, safety certification or independent model validation.

## 3. Demonstration scripts

Run each script separately:

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

Some demonstration scripts clear the workspace and close figures.

## 4. Pack sizing and validation

```matlab
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
Report = validatePack(Pack);
```

The pack mass estimate includes cell mass plus configured BMS, enclosure, busbar and wiring masses. Those hardware values are preliminary assumptions. The cost model remains cell-only. Cell-envelope volume is not the complete external pack volume.

Application limits should be explicit rather than assumed universal:

```matlab
Requirements.MaxPackVoltage_V = 60;
Requirements.MaxPackMass_kg = 5.0;
Requirements.MaxCellCount = 100;
Requirements.MinCapacity_Ah = 20;
Requirements.MinDischargeCurrent_A = 25;
Requirements.MinTemperature_C = -10;
Requirements.MaxTemperature_C = 55;
Validation = validatePack(Pack,Requirements);
```

The values above are illustrative; replace them with actual system requirements.

## 5. ECM prediction and protection

First-order ECM:

```matlab
[Vt,Vrc,OCV,Status] = batteryECM(SOC,Current,VrcOld,dt,Battery);
```

Second-order ECM:

```matlab
[Vt,Vrc1,Vrc2,OCV,Status] = batteryECM_2RC( ...
    SOC,Current,Vrc1Old,Vrc2Old,dt,Battery);
```

The voltage prediction is intentionally not clipped. Inspect `Status.OverVoltage`, `Status.UnderVoltage` and `Status.WithinVoltageLimits`. A supervisory protection layer must decide whether to inhibit current, derate operation or open contactors. OCV interpolation still extrapolates outside the tabulated SOC range; avoid out-of-range SOC and validate the source data.

## 6. Advanced demonstration modules

- `estimateSOC_EKF`: preliminary two-state EKF; tune process/measurement covariance and validate on independent data.
- `estimateSOH`: semi-empirical aging demonstration; coefficients require calibration to cell-specific aging tests.
- `passiveCellBalancing`: idealized shunt logic using (I=V/R); it does not model switching losses or thermal dynamics.
- `calcRegenerativeBraking`: simplified charge-current limits; not a validated lithium-plating or charge-acceptance model.
- `bmsProtectionLogic`: demonstration state machine; not an ISO 26262-compliant safety mechanism.
- `driveCycleDynamics`: synthetic drive-cycle approximation; do not label it a measured WLTP trace unless replaced with the official trace and verified interpolation.

## 7. Known limitations

- Cell parameters, 2RC branch values and pack hardware estimates need traceable sources.
- ECM is fixed-parameter; parameter identification over SOC, temperature and SOH is not yet established.
- Thermal model is lumped and simplified.
- SOH, balancing, fault diagnosis and protection logic require independent validation.
- Pack design is a bounded heuristic.
- No editable integrated Simulink `.slx` model is tracked.
- Run all tests in MATLAB Online/Desktop and record the actual test summary before claiming test success.
