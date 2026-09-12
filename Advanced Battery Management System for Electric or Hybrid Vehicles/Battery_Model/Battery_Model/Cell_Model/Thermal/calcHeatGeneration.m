function Heat = calcHeatGeneration(current, Battery)
% ==========================================================
% calcHeatGeneration.m
%
% Project:
% Modeling and Simulation of a Hybrid Electric Vehicle
% Powertrain in MATLAB/Simulink
%
% Description:
% Calculates battery heat generation using Joule heating.
%
% Equation:
% Heat = I^2 × R0
%
% Inputs:
% current  - Battery current (A)
% Battery  - Battery structure
%
% Output:
% Heat     - Heat generated (W)
%
% Author : Vishal Mishra
% ==========================================================

Heat = (current^2) * Battery.R0;

end