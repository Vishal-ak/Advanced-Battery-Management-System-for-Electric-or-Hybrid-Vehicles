# Configurable battery simulation

Run from the canonical `Battery_Model` folder:

```matlab
projectPaths = setupProject();
t = (0:1:1800)';
cfg = createSimulationConfig('CellID','Molicel_INR18650_P28A', ...
    'PackMode','manual','Ns',13,'Np',6, ...
    'LoadType','constant-current','Time',t,'Current',10, ...
    'InitialSOC',0.95,'InitialTemperature',25);
out = runConfigurableSimulation(cfg);
```

## Available cell profiles

| Library ID | Cell | Status |
|---|---|---|
| `Panasonic_NCR18650B` | Panasonic NCR18650B | Existing project profile; original project OCV table |
| `Molicel_INR18650_P28A` | Molicel P28A | Datasheet limits plus published C/20 pseudo-OCV lookup |
| `LG_INR18650_MJ1` | LG MJ1 | Datasheet limits; OCV table is an illustrative placeholder and must be replaced before quantitative use |

The Molicel P28A lookup is adapted from the published C/20 pseudo-OCV dataset at https://github.com/soorajsunil/Piecewise-Battery-OCV . The manufacturer datasheet is https://www.molicel.com/wp-content/uploads/INR18650P28A-V1-80093.pdf .

The LG MJ1 profile uses manufacturer specifications (3.635 V nominal, 3.35 Ah minimum design capacity, 4.2/2.5 V limits, 3.35 A maximum charge and 10 A maximum discharge; see https://files.batteryjunction.com/frontend/files/lg/datasheet/LG-MJ1-Datasheet.pdf ). Its current SOC-voltage CSV is only a placeholder, explicitly labelled as such in the profile. Replace it with full-cell OCV data from a verified source or lab characterization before using LG MJ1 for model validation. A public MJ1 electrochemical dataset is described at https://pmc.ncbi.nlm.nih.gov/articles/PMC7394852/ .

ECM and thermal parameters for the new profiles are not all identified from HPPC/thermal tests. The profile structs explicitly mark the provisional values. Do not interpret these as manufacturer-certified dynamic model parameters.

## Adding another cell
Create `Cell_Library/<ID>/Data/OCV_SOC.csv` with `SOC,OCV` columns and `Cell_Library/<ID>/Scripts/initCellProfile.m` returning a scalar Battery struct. Populate required electrical, physical, safety, ECM and thermal fields from traceable sources. The profile loader discovers these folders automatically.

## Pack configuration
- `manual`: choose integer `Ns` and `Np`.
- `target`: choose target voltage and Ah; selected-cell sizing rounds series and parallel counts upward.

## Load types
`constant-current`, `step`, `pulse`, `drive-cycle`, `custom-current`, and `power`. Positive current means discharge; negative means charge/regeneration. For `custom-current`, supply a current vector matching the time vector. The `power` mode currently converts requested power using nominal pack voltage; it is a fixed-current approximation, not a closed-loop constant-power load.

## Model limitations
The runner is a pack-equivalent 1RC ECM with coulomb counting and a lumped thermal state. It assumes identical cells and equal current sharing. It does not simulate individual-cell dispersion, cell balancing, contactor/protection switching, or a validated BMS controller. MATLAB execution and regression tests are still required before engineering use.
