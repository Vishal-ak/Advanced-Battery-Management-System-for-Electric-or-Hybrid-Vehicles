# Configurable battery simulation

Run from the canonical `Battery_Model` folder:

```matlab
projectPaths = setupProject();
t = (0:1:1800)';
cfg = createSimulationConfig('CellID','Panasonic_NCR18650B', ...
    'PackMode','manual','Ns',13,'Np',6, ...
    'LoadType','constant-current','Time',t,'Current',10, ...
    'InitialSOC',0.95,'InitialTemperature',25);
out = runConfigurableSimulation(cfg);
```

## Pack configuration
- `manual`: choose integer `Ns` and `Np`.
- `target`: choose target voltage and Ah; selected-cell sizing rounds series and parallel counts upward.

## Cell selection
`listCellProfiles` discovers cell folders with `Data/OCV_SOC.csv`. Currently Panasonic NCR18650B is the only loadable profile. A new profile requires `Data/OCV_SOC.csv` with `SOC,OCV` columns and `Scripts/initCellProfile.m` returning a scalar Battery struct with the fields required by `createBatteryPack` and `batteryECM`. Populate parameters from traceable datasheet or characterization sources; do not copy another chemistry's ECM/thermal values.

## Load types
`constant-current`, `step`, `pulse`, `drive-cycle`, `custom-current`, and `power`. Positive current means discharge; negative means charge/regeneration. For `custom-current`, supply a current vector matching the time vector. The `power` mode currently converts requested power using nominal pack voltage; it is a fixed-current approximation, not a closed-loop constant-power load.

## Model limitations
The runner is a pack-equivalent 1RC ECM with coulomb counting and a lumped thermal state. It assumes identical cells and equal current sharing. It does not simulate individual-cell dispersion, cell balancing, contactor/protection switching, or a validated BMS controller. MATLAB execution and regression tests are still required before engineering use.
