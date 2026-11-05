# Battery Management System — MATLAB Project

This directory is the canonical MATLAB source tree for the HEV/EV battery modelling project.

## Start here

1. Open this folder as the MATLAB Current Folder.
2. Run: projectPaths = setupProject();
3. Follow EXECUTION_GUIDE.md for the step-by-step execution sequence, script descriptions, outputs and known limitations.

## Main modules

| Folder | Responsibility |
|---|---|
| Parameters | Cell initialization and parameter structure |
| Cell_Library | Panasonic NCR18650B data and documentation |
| Cell_Model/ECM | 1RC equivalent-circuit model |
| Cell_Model/Thermal | Lumped thermal model |
| SOC | Coulomb-counting SOC update |
| Simulation/CurrentProfile | Test current profiles |
| BatteryPack | Pack construction, sizing and validation |
| Pack_Database | Commercial pack database and recommendation |
| Tests | Existing demonstration scripts |

## Directory policy

The nested Battery_Model/Battery_Model/ folder is a legacy duplicate containing overlapping source files and additional outputs/cache artifacts. The top-level folders listed above are the canonical source. Do not add the nested duplicate to the MATLAB path. Its contents will be reconciled separately before deletion or migration.

## Current implementation scope

The repository currently contains a first-order ECM, Coulomb-counting SOC, a simple lumped thermal model, pack design utilities and a commercial pack database workflow. Advanced SOC/SOH estimation, cell balancing, fault diagnosis and an integrated BMS are planned research extensions, not completed features.

See EXECUTION_GUIDE.md for limitations and the research roadmap.
