# Model Reference and Engineering Conventions

This document describes the MATLAB models present in the tracked source tree. It is not a substitute for cell characterization, manufacturer limits or a validated BMS safety concept.

## 1. Reference cell and parameter provenance

The configured reference cell is Panasonic NCR18650B. The project initializer, `Parameters/initBattery.m`, is the runtime source for the current model parameters. Its values must be reconciled against the exact manufacturer datasheet revision and documented test conditions before being described as manufacturer specifications.

The current initialization includes (V_{nom}=3.70\,V), (V_{max}=4.20\,V), (V_{cutoff}=2.50\,V), design capacity (3.35\,Ah), (R_0=0.045\,\Omega), (R_1=0.012\,\Omega), (C_1=2400\,F), and preliminary 2RC values (R_2=0.015\,\Omega), (C_2=8000\,F). A separate `InternalResistance=0.05 Ω` is also present; this must be reconciled rather than silently treated as identical to the ECM's (R_0).

The OCV–SOC CSV is loaded from `Cell_Library/Panasonic_NCR18650B/Data/OCV_SOC.csv`. Its provenance, measurement temperature, rest period, charge/discharge direction, SOC reference and preprocessing are not established by the data file alone.

## 2. Sign conventions and units

| Quantity | Convention |
|---|---|
| Current | Positive = discharge; negative = charge |
| SOC | Fraction from 0 to 1 |
| Voltage | Volts (V) |
| Current | Amperes (A) |
| Capacity | Ah, converted to coulombs where required |
| Time | Seconds (s) |
| Resistance | Ohms (Ω) |
| Capacitance | Farads (F) |
| Temperature | °C for reported temperature; temperature difference in K |
| Energy | Wh or kWh, as labelled |

## 3. OCV lookup

The ECM obtains open-circuit voltage by interpolation:

[
V_{OC}=f(SOC)
]

In the current implementation, OCV lookup is a model input to the ECM. It is not an independent online SOC estimator. The tracked coulomb-counting function does not use terminal-voltage feedback or perform a rest-detection correction.

The table must have finite, unique, monotonically increasing SOC entries and matching finite OCV values. Lookup should be bounded to its characterized SOC range; extrapolation outside the data range should not be treated as validated behavior.

## 4. First-order Thevenin ECM (1RC)

The model consists of an OCV source, a series ohmic resistance (R_0), and one parallel polarization branch (R_1-C_1).

With positive current defined as discharge:

[
V_t=V_{OC}(SOC)-IR_0-V_{RC}
]

[
\frac{dV_{RC}}{dt}=-\frac{V_{RC}}{R_1C_1}+\frac{I}{C_1}
]

For a zero-order-held current over (Delta t), the exact discrete update used by `updateRCVoltage.m` is:

[
V_{RC,k+1}=e^{-\Delta t/(R_1C_1)}V_{RC,k}
+R_1(1-e^{-\Delta t/(R_1C_1)})I_k
]

The terminal-voltage prediction is not clipped to cell limits. The 1RC function reports overvoltage and undervoltage flags. A full supervisory protection response is not implemented by this ECM function.

## 5. Second-order Thevenin ECM (2RC)

The optional model adds a second polarization branch:

[
V_t=V_{OC}(SOC)-IR_0-V_{RC1}-V_{RC2}
]

The two branches represent different dynamic time constants. The currently initialized (R_2,C_2) values are preliminary and require parameter identification against traceable pulse or dynamic-test data. A second branch does not automatically make predictions more accurate.

## 6. State of charge

The implemented SOC update is Coulomb counting:

[
SOC_{k+1}=\operatorname{clip}_{[0,1]}
\left(SOC_k-\frac{I_k\Delta t}{3600Q_{Ah}}\right)
]

Positive current decreases SOC; negative current increases SOC. The current function assumes current in A, time in seconds and capacity in Ah. It clips to [0,1] and does not model coulombic efficiency, current-sensor bias, self-discharge or capacity fade.

The OCV table supplies (V_{OC}) to the ECM for a given SOC. **This is not OCV-based SOC correction.** A true OCV-rest correction would require rest detection, hysteresis/temperature treatment and a validated lookup procedure. No EKF is established as part of the verified core implementation.

## 7. Lumped thermal model

The thermal model is a single-node approximation:

[
m c_p\frac{dT}{dt}=\dot Q_{gen}-\frac{T-T_{amb}}{R_{th}}
]

The current heat-generation implementation uses irreversible ohmic heating:

[
\dot Q_{gen}=I^2R_0
]

This omits reversible entropic heat, temperature-dependent parameters and internal temperature gradients. The temperature update uses explicit Euler integration, whose accuracy depends on the time step relative to the thermal time constant (m c_pR_{th}). It is not a thermal-runaway or propagation model.

## 8. Pack scaling

For (N_s) series cells and (N_p) parallel strings, assuming identical cells and ideal interconnections:

[
V_{pack}=N_sV_{cell},\qquad Q_{pack}=N_pQ_{cell}
]

[
R_{pack}=R_{cell}\frac{N_s}{N_p},\qquad
N_{cells}=N_sN_p
]

Nominal energy is approximated as (E_{Wh}=V_{nom,pack}Q_{Ah,pack}). These relations neglect mismatch, interconnect resistance, cooling, balancing currents, thermal gradients and dynamic limits.

The pack mass estimate includes cell mass plus configured pack-level hardware allowances. The volume estimate uses summed cell-envelope volume only, not complete assembled-pack volume. The pack design cost estimate is cell-only.

## 9. Pack sizing and validation

The custom pack-sizing routine evaluates a bounded search window around estimated series/parallel counts and uses a weighted heuristic score. It is not a global optimizer and does not currently guarantee electrical, thermal, mechanical, cost or safety feasibility beyond its explicit checks.

The pack validator performs internal consistency checks and evaluates application limits only when supplied by the caller. Missing application requirements are not universal defaults.

The commercial pack recommender calculates a weighted score from normalized voltage/capacity mismatch, mass and volume. Its current implementation needs robust handling of invalid values and zero normalization ranges before the result should be used for design decisions.

## 10. Passive balancing

The current function selects cells whose voltages exceed the minimum cell voltage by a configurable threshold, under a simplified top-balance enable condition. Enabled shunts use the ideal relation:

[
I_{bleed}=\frac{V_{cell}}{R_{bleed}}
]

The code does not model resistor temperature, switching losses, cell impedance, balancing duration or an experimentally validated control policy.

## 11. Regenerative-braking current estimate

The regenerative-braking function applies simple SOC and temperature derating factors and constrains charge current using a configured limit and a simplified voltage-headroom calculation. It is not a validated electrochemical charge-acceptance or lithium-plating model. Real charge acceptance depends on cell chemistry, condition, temperature, SOC, current history and manufacturer restrictions.

## 12. Model-validation requirements

Identify parameters from traceable cell tests. Separate calibration and held-out validation datasets. Compare predicted voltage, SOC and temperature with independent measurements. Report RMSE, MAE, maximum absolute error, operating conditions, data provenance and uncertainty. Unit tests alone do not establish predictive accuracy.
