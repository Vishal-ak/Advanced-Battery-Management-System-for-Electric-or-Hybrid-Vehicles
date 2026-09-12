function [Energy_Wh,Energy_kWh] = packEnergy(packVoltage,capacity)
%===========================================================
% packEnergy.m
%
% Calculates battery pack energy.
%
% Equation:
% Energy = Voltage × Capacity
%
%===========================================================

Energy_Wh = packVoltage * capacity;

Energy_kWh = Energy_Wh/1000;

end