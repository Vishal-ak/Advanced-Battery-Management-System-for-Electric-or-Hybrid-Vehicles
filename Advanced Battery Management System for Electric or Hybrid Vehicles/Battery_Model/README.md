# Battery Model — MATLAB Project

This folder is the canonical MATLAB source tree for the EV/HEV battery modelling project.

## Quick start

Set MATLAB Current Folder to this directory:

```matlab
projectPaths = setupProject();
Battery = initBattery();
results = runAllTests();
```

A successful call to `runAllTests` means the automated test assertions passed in that MATLAB run. It does not establish experimental model validity or safety qualification.

## Implemented modules

- **Cell parameters/data:** Panasonic NCR18650B reference parameter initialization and OCV–SOC table loading.
- **Electrical cell model:** First-order Thevenin ECM (1RC), with an optional second-order (2RC) implementation.
- **SOC:** Coulomb counting. The OCV–SOC lookup supports the ECM open-circuit-voltage calculation; it is not by itself an online SOC correction observer.
- **Thermal:** Lumped single-node temperature update and ohmic heat generation.
- **Pack:** Series/parallel pack creation, arithmetic utilities, heuristic sizing, validation and pack-database comparison.
- **Balancing:** Simplified idealized passive shunt logic.
- **Regeneration:** Simplified regenerative charge-current estimate with current limits.
- **Simulation:** Constant, step, pulse and synthetic drive-cycle current inputs.
- **Tests:** MATLAB demonstration scripts and automated unit tests.

## Not included as verified core features

No verified EKF SOC estimator, SOH/aging estimator, fault-diagnosis system, validated supervisory protection state machine, active thermal controller, or tracked integrated Simulink model is established by the current core source inventory. Do not list these as implemented until the source, execution instructions and tests exist.

## Important modelling boundaries

- ECM parameters are fixed project inputs until identified against traceable test data.
- The 2RC branch values are preliminary.
- The OCV table's provenance, test temperature, rest period and SOC reference method need to be recorded.
- The thermal model is a single-node approximation. Heat generation currently uses `I^2 R0`; reversible heat and distributed gradients are not included.
- Pack sizing is a bounded heuristic, not a global optimum.
- Mass includes configured pack-level hardware allowances; these are estimates.
- Volumetric density uses cell-envelope volume only, not total assembled pack volume.
- Estimated cost is cell-only and excludes pack hardware and assembly.
- Passive balancing and regenerative braking are educational prototypes, not production control algorithms.
- No ISO 26262 compliance or safety certification is claimed.

See [EXECUTION_GUIDE.md](EXECUTION_GUIDE.md), [Documentation/MODEL_REFERENCE.md](Documentation/MODEL_REFERENCE.md), and [Documentation/VALIDATION_STATUS.md](Documentation/VALIDATION_STATUS.md).
