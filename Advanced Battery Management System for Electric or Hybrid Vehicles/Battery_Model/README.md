# Battery Model — MATLAB Project

This folder is the canonical MATLAB source tree for the EV/HEV battery modelling project.

## Quick start

Set MATLAB Current Folder to this directory:

```matlab
projectPaths = setupProject();
Battery = initBattery();
results = runAllTests();
```

Launch the interactive simulation dashboard:

```matlab
app = BMSDashboard();
```

A successful call to `runAllTests` means the automated test assertions passed in that MATLAB run. It does not establish experimental model validity or safety qualification.

## Implemented modules

- **Cell data:** Panasonic NCR18650B reference parameter initialization and OCV–SOC table loading.
- **Electrical cell model:** first-order Thevenin ECM (1RC) and optional second-order ECM (2RC).
- **SOC:** Coulomb counting. OCV lookup supplies the ECM open-circuit voltage; it does not itself implement rested-voltage SOC correction.
- **Thermal:** lumped single-node temperature update and ohmic heat generation.
- **Pack:** series/parallel pack creation, arithmetic utilities, heuristic sizing, validation and pack-database comparison.
- **Balancing:** simplified idealized passive shunt logic.
- **Regeneration:** simplified regenerative charge-current estimate with configured current and charge-temperature limits.
- **Simulation:** pack-scaled synthetic, constant-discharge, constant-charge, step and pulse current profiles; a simulation service couples ECM, SOC and thermal states and enforces configured current/SOC limits.
- **Dashboard:** interactive MATLAB simulation UI with current, voltage, SOC and temperature plots and CSV export.
- **Tests:** MATLAB demonstration scripts and automated unit tests.

## Reference-cell ratings and example pack

The included Panasonic NCR18650B reference datasheet specifies 3.6 V nominal voltage, 3.35 Ah typical capacity, 3.25 Ah minimum capacity, 4.2 V charging voltage, 2.5 V discharge cutoff and 1.625 A standard charge current. The charge ambient temperature range is 0–45 °C; below 10 °C the datasheet footnote specifies charging at 0.25C.

An ideal 13S6P configuration calculates to 46.8 V nominal, 54.6 V maximum, 32.5 V cutoff, 20.1 Ah and 940.68 Wh nominal energy. Its calculated standard charge-current level is 9.75 A for six parallel cells with ideal current sharing; below 10 °C the 0.25C rule gives 5.025 A pack current.

The 5 A cell discharge current in the initializer is a conservative project model limit, not a quoted maximum rating from the referenced datasheet. ECM R0/R1/C1/R2/C2, thermal parameters and cell-resistance values remain modelling parameters requiring characterization.

## Engineering limitations

- Verify the exact reference-cell datasheet revision and tube/bare-cell dimensional basis.
- The cathode chemistry is not asserted where the referenced datasheet does not specify it.
- The OCV table provenance, temperature, rest period and SOC calibration need traceable documentation.
- The 2RC branch values are preliminary.
- The thermal model is single-node and heat generation currently uses (I^2R_0).
- Pack sizing is a bounded heuristic, not a global optimizer.
- Pack mass includes configurable pack-level hardware estimates; volume is cell-envelope-only; estimated cost is cell-only.
- Passive balancing and regenerative-braking algorithms are educational prototypes, not production safety functions.
- Regenerative charge acceptance remains simplified; no electrochemical or lithium-plating model is implemented.
- The dashboard is an offline simulation UI, not a live hardware BMS interface. It includes a constant-charge case and reports SOC-boundary current limiting.
- No ISO 26262 compliance or functional-safety certification is claimed.
- Run MATLAB tests locally before relying on a result. Repository updates do not imply runtime test success.

See [EXECUTION_GUIDE.md](EXECUTION_GUIDE.md), [Documentation/MODEL_REFERENCE.md](Documentation/MODEL_REFERENCE.md), [Documentation/VALIDATION_STATUS.md](Documentation/VALIDATION_STATUS.md) and [Documentation/PROJECT_REPORT.md](Documentation/PROJECT_REPORT.md).
