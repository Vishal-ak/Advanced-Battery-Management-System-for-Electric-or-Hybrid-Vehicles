function T_new = updateTemperature(T_old, Heat, T_ambient, dt, Battery)
% ==========================================================
% updateTemperature.m
%
% Project:
% Modeling and Simulation of a Hybrid Electric Vehicle
% Powertrain in MATLAB/Simulink
%
% Description:
% Updates battery temperature using a first-order
% lumped thermal model.
%
% Equation:
% dT/dt = (Q - (T-Tamb)/Rth)/(m*Cp)
%
% Inputs:
% T_old      - Previous battery temperature (°C)
% Heat       - Heat generation (W)
% T_ambient  - Ambient temperature (°C)
% dt         - Time step (s)
% Battery    - Battery structure
%
% Output:
% T_new      - Updated battery temperature (°C)
%
% Author: Vishal Mishra
% ==========================================================

m = Battery.Mass;

Cp = Battery.SpecificHeat;

Rth = Battery.ThermalResistance;

Cooling = (T_old - T_ambient) / Rth;

dTdt = (Heat - Cooling) / (m * Cp);

T_new = T_old + dTdt * dt;

end