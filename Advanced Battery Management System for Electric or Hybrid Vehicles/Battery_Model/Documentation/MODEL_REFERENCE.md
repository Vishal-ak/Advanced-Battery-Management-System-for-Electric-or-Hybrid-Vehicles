# Model Reference and Engineering Conventions

This document describes the MATLAB models present in the tracked source tree. It is not a substitute for cell characterization, manufacturer limits or a validated BMS safety concept.

## 1. Reference cell and parameter provenance

The configured reference cell is Panasonic NCR18650B. The included Panasonic NCR18650B reference datasheet specifies 3.6 V nominal voltage, 3.35 Ah typical capacity, 3.25 Ah minimum capacity, 4.20 V charging voltage, 2.50 V discharge cutoff and 1.625 A standard charge current. Consult the exact datasheet revision stored in `Cell_Library/Panasonic_NCR18650B/Datasheet/` before hardware use.

The manufacturer charge-temperature window is 0–45 °C. The datasheet footnote instructs a reduced 0.25C charge rate below 10 °C. The runtime initializer represents these as a charge-temperature window and a separate low-temperature current limit. The configured 5 A cell discharge limit is a project modelling limit, not a maximum rating established by the referenced datasheet.

The project carries `InternalResistance=0.050 Ω` and ECM `R0=0.045 Ω`; neither value is established by the cell datasheet as a fixed universal resistance. R0, R1, C1, R2 and C2 require cell-characterization and parameter-identification evidence. Thermal parameters are project assumptions.

The cathode chemistry is not inferred from the model name where the cited datasheet does not identify the cathode composition. OCV table provenance, test temperature, rest period, charge/discharge direction, SOC reference method and preprocessing are not established by the CSV file alone.

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

The current initializer validates equal-length finite SOC and OCV vectors and strictly increasing SOC in [0,1]. OCV is an input to ECM voltage prediction. It is not an independent online SOC estimator, and the Coulomb-counting function does not perform rest-based voltage correction.

The quality of the OCV estimate depends on the source dataset, cell chemistry, temperature, rest period, SOC calibration and interpolation range. The table provenance and conditions must be recorded before it is treated as a reference dataset.

## 4. First-order Thevenin ECM (1RC)

The model consists of an OCV source, series ohmic resistance R0, and one parallel polarization branch R1-C1.

With positive current defined as discharge:

[
V_t=V_{OC}(SOC)-IR_0-V_{RC}
]

[
\frac{dV_{RC}}{dt}=-\frac{V_{RC}}{R_1C_1}+\frac{I}{C_1}
]

For a zero-order-held current over (Delta t), the exact discrete update is:

[
V_{RC,k+1}=e^{-\Delta t/(R_1C_1)}V_{RC,k}
+R_1(1-e^{-\Delta t/(R_1C_1)})I_k
]

The terminal-voltage prediction is not clipped to cell limits. The 1RC function reports overvoltage and undervoltage flags. A complete supervisory protection response is not implemented by this ECM function.

## 5. Second-order Thevenin ECM (2RC)

The optional model adds a second polarization branch:

[
V_t=V_{OC}(SOC)-IR_0-V_{RC1}-V_{RC2}
]

The two branches represent different dynamic time constants. The implementation includes independent discrete state updates for each branch. The currently initialized R2/C2 values are preliminary and require parameter identification against traceable pulse or dynamic-test data.

## 6. State of charge

The implemented SOC update is Coulomb counting:

[
SOC_{k+1}=\operatorname{clip}_{[0,1]}
\left(SOC_k-\frac{I_k\Delta t}{3600Q_{Ah}}\right)
]

Positive current decreases SOC; negative current increases SOC. Inputs are current in A, time in seconds and capacity in Ah. The function clips SOC to [0,1] and does not model coulombic efficiency, sensor bias, self-discharge or capacity fade.

The OCV lookup supplies VOC to the ECM. **This is not OCV-based SOC correction.** Such correction would require rest detection, hysteresis/temperature treatment and a validated lookup procedure. No EKF is established as part of the verified core implementation.

## 7. Lumped thermal model

The thermal model is a single-node approximation:

[
m c_p\frac{dT}{dt}=\dot Q_{gen}-\frac{T-T_{amb}}{R_{th}}
]

The heat-generation implementation uses irreversible ohmic heating:

[
\dot Q_{gen}=I^2R_0
]

This omits reversible entropic heat, temperature-dependent properties and internal gradients. The temperature update uses explicit Euler integration; verify timestep adequacy relative to the thermal time constant (m c_pR_{th}). It is not a thermal-runaway or propagation model.

## 8. Pack scaling

For Ns series cells and Np parallel strings, assuming identical cells and ideal interconnections:

[
V_{pack}=N_sV_{cell},\qquad Q_{pack}=N_pQ_{cell}
]

[
R_{pack}=R_{cell}\frac{N_s}{N_p},\qquad N_{cells}=N_sN_p
]

Nominal energy is approximated as (E_{Wh}=V_{nom,pack}Q_{Ah,pack}). These relationships neglect cell mismatch, interconnect resistance, cooling, balancing currents, thermal gradients and dynamic limits.

Using 3.6 V nominal and 3.35 Ah typical capacity, a 13S6P pack calculates to 46.8 V nominal, 54.6 V maximum, 32.5 V cutoff, 20.1 Ah and 940.68 Wh nominal energy. Its ideal standard charge-current scaling is 9.75 A for six parallel cells. Below 10 °C, the manufacturer footnote specifies 0.25C per cell, corresponding to 5.025 A for six parallel cells. These are arithmetic pack limits under ideal current sharing, not measured pack results.

The pack mass estimate includes cell mass plus configured pack-level hardware allowances. The volume estimate uses summed cell-envelope volume only, not complete assembled-pack volume. The custom pack design cost estimate is cell-only.

## 9. Pack sizing and validation

The custom pack-sizing routine evaluates a bounded search window around estimated series/parallel counts and uses a weighted heuristic score. It is not a global optimizer and does not guarantee electrical, thermal, mechanical, cost or safety feasibility beyond explicit checks.

Commercial pack recommendation uses normalized voltage/capacity mismatch, mass and volume. Invalid rows are filtered and zero-range normalization is handled in the audit branch. Recommendations remain heuristic and depend on source-data provenance and completeness.

## 10. Passive balancing

The current function selects cells whose voltages exceed the minimum cell voltage by a configurable threshold under a simplified top-balance enable condition. Enabled shunts use:

[
I_{bleed}=\frac{V_{cell}}{R_{bleed}}
]

The code does not model resistor temperature, switching losses, cell impedance, balancing duration or an experimentally validated control policy.

## 11. Regenerative-braking current estimate

The regenerative-braking function applies a project SOC derating heuristic, constrains charging to the configured 0–45 °C cell charge-temperature window, applies the manufacturer's 0.25C current limit below 10 °C, and uses a simplified pack voltage-headroom current limit. It is not a validated electrochemical charge-acceptance or lithium-plating model. Real charge acceptance depends on cell chemistry, condition, temperature, SOC, current history and manufacturer limits.

## 12. Model-validation requirements

Identify parameters from traceable cell tests. Separate calibration and held-out validation datasets. Compare predicted voltage, SOC and temperature with independent measurements. Report RMSE, MAE, maximum absolute error, operating conditions, data provenance and uncertainty. Unit tests alone do not establish predictive accuracy.
