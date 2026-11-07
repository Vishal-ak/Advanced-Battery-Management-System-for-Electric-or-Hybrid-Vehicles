# Battery Model — MATLAB Project

This is the canonical MATLAB source tree for the EV/HEV battery modelling project.

## Quick start

```matlab
projectPaths = setupProject();
Battery = initBattery();
results = runAllTests();
```

See [EXECUTION_GUIDE.md](EXECUTION_GUIDE.md) for demonstrations and detailed execution order.

## Modules

- **Cell model:** first-order Thevenin ECM; optional second-order (2RC) model.
- **SOC:** Coulomb counting and an experimental EKF estimator.
- **Thermal:** lumped thermal model, heat-generation extensions and a supervisory thermal controller.
- **Aging:** semi-empirical SOH estimator (requires calibration before predictive use).
- **Pack:** series/parallel sizing, pack calculations, passive balancing and supervisory protection logic.
- **Simulation:** current profiles, regenerative-braking calculations and illustrative road-load drive-cycle simulation.
- **Tests:** demonstration scripts and automated unit tests.

## Engineering limitations

- The EKF process/measurement noise and the SOH degradation coefficients are illustrative until identified against independent experimental data.
- The drive-cycle generator is synthetic/illustrative; it must not be described as an official WLTP or UDDS trace.
- Pack mass includes configured pack-level hardware mass estimates. Replace them with sourced/measured component values.
- Pack volume is the sum of cell envelopes only. It excludes enclosure, cooling, busbars and clearances; therefore the associated Wh/L figure is not complete-pack energy density.
- Estimated pack cost is currently cell-only and excludes BMS, enclosure, interconnects, assembly and validation.
- ECM voltage output is not clipped. Voltage violations are reported for supervisory protection logic to handle.
- The protection and balancing algorithms are educational prototypes, not safety-certified implementations. No ISO 26262 compliance or functional-safety certification is claimed.
- The pack designer uses a bounded heuristic search, not a global optimizer.
- Run MATLAB tests locally before relying on a result. Repository updates do not imply runtime test success.

Advanced estimation, aging, balancing, fault handling and thermal management require experimental calibration and independent validation before deployment.
