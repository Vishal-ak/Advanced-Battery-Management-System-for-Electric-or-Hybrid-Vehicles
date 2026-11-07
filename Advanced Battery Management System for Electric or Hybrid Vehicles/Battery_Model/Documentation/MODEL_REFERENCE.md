# Model Reference and Engineering Conventions

This document describes the models present in the MATLAB source tree. It is not a substitute for cell characterization, manufacturer limits or a validated BMS safety concept.

## 1. Reference cell

The project initializes a Panasonic NCR18650B cylindrical cell. The nominal values in code and the cell-library documents are model inputs, not a guarantee that every physical cell has those exact properties.

Use the manufacturer datasheets in `Cell_Library/Panasonic_NCR18650B/Datasheet/` as the primary reference for operating limits. Record the exact datasheet revision and test conditions when citing a numerical value. The model's selected capacity, resistance and thermal parameters should be treated as assumptions unless a traceable measurement or source is recorded.

## 2. Sign conventions and units

| Quantity | Convention |
|---|---|
| Current | Positive = discharge; negative = charge |
| SOC | Fraction from 0 to 1 |
| Voltage | Volts (V) |
| Current | Amperes (A) |
| Capacity | Ampere-hours (Ah), or coulombs (C) where explicitly stated |
| Time | Seconds (s) |
| Resistance | Ohms (Ω) |
| Capacitance | Farads (F) |
| Temperature | Degrees Celsius for reported temperature; temperature differences are equivalent in K |
| Energy | Wh or kWh, as labelled |

Maintain this convention consistently when constructing current profiles or comparing outputs.

## 3. OCV–SOC lookup

The open-circuit voltage is obtained from a tabulated relationship:

[
V_{OC}=f(SOC)
]

The MATLAB implementation interpolates the stored OCV–SOC data. OCV is not the same as loaded terminal voltage: under current, ohmic and polarization drops must also be considered.

The quality of the OCV estimate depends on the source dataset, cell chemistry, temperature, rest period, SOC calibration and interpolation range. Do not describe the table as measured in this project unless its provenance and test procedure are documented.

## 4. First-order Thevenin ECM (1RC)

The first-order model represents the cell with an OCV source, a series ohmic resistance (R_0), and one parallel polarization (R_1-C_1) branch.

With positive current defined as discharge:

[
V_t = V_{OC}(SOC)-I R_0-V_{RC}
]

The polarization state follows:

[
rac{dV_{RC}}{dt}=-rac{V_{RC}}{R_1C_1}+rac{I}{C_1}
]

For a zero-order-held current over a time step (Delta t), the exact discrete update is:

[
V_{RC,k+1}=e^{-Delta t/(R_1C_1)}V_{RC,k}
+R_1left(1-e^{-Delta t/(R_1C_1)}ight)I_k
]

This model is a compact approximation of dynamic voltage response. It does not explicitly resolve electrochemical diffusion or spatial gradients.

## 5. Second-order Thevenin ECM (2RC)

The optional 2RC model adds a second polarization branch:

[
V_t=V_{OC}(SOC)-IR_0-V_{RC1}-V_{RC2}
]

Each branch has its own resistance-capacitance time constant. A second branch can represent an additional dynamic timescale, but it does not automatically make the model more accurate. The values of (R_2) and (C_2) currently added to the initialized parameter structure are preliminary and require parameter identification against pulse or dynamic test data.

## 6. Terminal-voltage limits

The ECM returns its predicted terminal voltage without clipping it to the configured maximum or cutoff voltage. It also returns status flags for overvoltage and undervoltage.

This separation is intentional: clipping a physical model output can hide a predicted limit violation. A supervisory BMS would need a separate, validated response such as current derating or contactor control. The current MATLAB functions only report status; they are not a complete protection architecture.

## 7. State of charge by Coulomb counting

The implemented SOC function updates charge state by integrating current:

[
SOC_{k+1}=SOC_k-rac{eta I_kDelta t}{Q_n}
]

where (Q_n) is capacity in coulombs and (eta) is the applicable coulombic-efficiency convention. Confirm the function's actual argument units and efficiency handling before applying this equation to a particular call. Numerical drift can arise from current-sensor bias, capacity uncertainty, efficiency assumptions and initial-SOC error.

An EKF or other observer is not currently included as a validated module in the tracked source tree.

## 8. Lumped thermal model

The thermal model is a lumped approximation: it treats the cell as a single thermal node rather than resolving internal or surface temperature gradients.

A generic energy balance is:

[
m c_prac{dT}{dt}=dot Q_{gen}-dot Q_{out}
]

The implemented heat-generation and temperature-update functions use the parameters defined by the project. The model should not be interpreted as a thermal-runaway model or a substitute for distributed thermal analysis. Validate heat-generation assumptions, thermal resistance and heat capacity against measured data before making temperature-safety claims.

## 9. Battery-pack scaling

For (N_s) cells in series and (N_p) parallel strings, assuming identical cells and ideal interconnections:

[
V_{pack}=N_sV_{cell},qquad
Q_{pack}=N_pQ_{cell}
]

[
R_{pack}=R_{cell}rac{N_s}{N_p},qquad
N_{cells}=N_sN_p
]

Nominal energy is approximated as (E_{Wh}=V_{nom,pack}Q_{Ah,pack}). These relationships neglect interconnect resistance, cell mismatch, thermal gradients, balancing currents and dynamic limits.

The pack mass estimate includes cell mass plus configured BMS, enclosure, busbar and wiring allowances. The hardware values are estimates. The reported volumetric energy density uses summed cell-envelope volume and is not the complete external pack density. The current design cost estimate is cell-only.

## 10. Pack sizing and validation

The pack-sizing routine searches a bounded neighbourhood around an initial series/parallel estimate and scores feasible candidates. It is a heuristic, not a proof of global optimality. Its result depends on the search window, score weights and input assumptions.

The pack validator checks internal consistency and any application-specific limits supplied by the caller. Unspecified application limits should remain unspecified rather than being presented as universal battery limits.

## 11. Passive balancing and regenerative braking

The passive-balancing function is a simplified switched-shunt demonstration. Its ideal resistor current follows (I_{bleed}=V_{cell}/R_{bleed}) when a shunt is enabled. The implementation does not model switch losses, resistor thermal rise, cell impedance, balancing energy or a complete charge-state-dependent control policy.

The regenerative-braking function estimates a simplified charge-current limit using SOC, temperature and voltage-headroom factors. It is not a validated electrochemical charge-acceptance or lithium-plating model. Real charge acceptance depends on cell condition, temperature, SOC, current history and manufacturer constraints.

## 12. Model validation requirements

Before making quantitative performance claims, identify model parameters from traceable cell tests, separate calibration and validation datasets, compare predictions with independent measurements, report error metrics and document operating conditions. Unit tests alone do not establish predictive accuracy.
