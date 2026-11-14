# MATLAB Execution Guide

## 1. Setup

Set MATLAB Current Folder to this `Battery_Model` directory, then run:

```matlab
projectPaths = setupProject();
Battery = initBattery();
```

Check function resolution when troubleshooting:

```matlab
which initBattery -all
which batteryECM -all
```

## 2. Automated tests

```matlab
results = runAllTests();
```

The automated suite currently covers selected ECM, SOC and thermal assertions. Passing these tests does not constitute hardware qualification, model validation against measured data, or safety certification.

## 3. Demonstrations

Run scripts individually from this directory:

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

## 4. New model modules

- `batteryECM`: first-order Thevenin model. Returns an unclipped voltage prediction and a fourth output, `Status`, with over/under-voltage flags.
- `batteryECM_2RC`: second-order dual-polarization model; requires R2/C2 in the cell parameter structure.
- `estimateSOC_EKF`: experimental SOC estimator using terminal-voltage feedback.
- `estimateSOH`: semi-empirical capacity-fade and resistance-growth estimator.
- `passiveCellBalancing`: switched shunt-resistor balancing prototype.
- `bmsProtectionLogic`: supervisory state-machine prototype.
- `thermalManagementController`: illustrative active heating/cooling controller.
- `driveCycleDynamics`: synthetic road-load/velocity profile generator, not an official WLTP/UDDS data trace.

## 5. Pack sizing and interpretation

```matlab
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6);
Validation = validatePack(Pack);
```

The estimated pack mass includes cell mass plus configured pack-level BMS, enclosure, busbar and wiring allowances. Those allowances are estimates, not measured masses.

The reported pack volume and Wh/L value use the sum of cell envelopes only. They exclude enclosure, cooling, busbars, spacing and other packaging overhead, so do not compare that value directly with a commercial pack's complete-pack volumetric energy density.

The cost estimate is cell-only. It excludes pack hardware, assembly, testing and logistics.

## 6. Application requirements

Use project-specific requirements rather than universal fixed thresholds:

```matlab
Req.MaxPackVoltage_V = 60;
Req.MaxPackMass_kg = 5;
Req.MaxCellCount = 100;
Req.MinCapacity_Ah = 20;
Req.MinDischargeCurrent_A = 25;
Validation = validatePack(Pack,Req);
```

The numbers above are examples only. Supply values from the actual system requirements.

## 7. Limitations

The EKF and SOH model require parameter identification and validation against independent data. The drive-cycle generator is illustrative. The balancing, protection and thermal-management algorithms are educational prototypes, not certified safety functions. No ISO 26262 compliance is claimed. The pack design search is heuristic. No editable integrated Simulink `.slx` model is included in this source tree.


## 8. Monitoring dashboard

Launch the interactive MATLAB monitoring dashboard from this canonical `Battery_Model` folder:

```matlab
setupProject();
BMSDashboard
```

Use the left panel to select 1RC or 2RC, choose a current profile, set initial SOC, simulation duration, time step and ambient temperature, then select **Run simulation**. The Monitoring tab displays terminal voltage and OCV, SOC, current and temperature. The Pack tab calculates series/parallel pack estimates. The Results tab displays the simulation table. Use the export buttons to save simulation data as CSV and plots as PNG plus editable FIG under `Results/Dashboard`.

The dashboard is a simulation monitor, not a live battery-hardware interface. Positive current means discharge. The synthetic dynamic profile is illustrative, not a standardized drive-cycle trace. Pack mass and cell-envelope volume are estimates; the latter excludes enclosure and cooling packaging.

## 9. Figure export and Results organization

The shared `saveBMSFigure` utility creates category folders under `Results`, exports 300 dpi PNG files and saves editable MATLAB FIG files. The dashboard uses this utility for its plot export. Individual legacy demonstration scripts may still contain their own export logic; verify their output paths when using them.

See [RESULTS_AND_FIGURE_MANAGEMENT.md](Documentation/RESULTS_AND_FIGURE_MANAGEMENT.md) for the folder taxonomy, naming convention, reproducibility requirements, and interpretation limitations.
