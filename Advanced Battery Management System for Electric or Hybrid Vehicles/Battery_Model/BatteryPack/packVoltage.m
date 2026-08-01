function Vpack = packVoltage(cellVoltage, Pack)
%===========================================================
% packVoltage.m
%
% Calculates battery pack voltage.
%
% Equation:
% Vpack = Ns × Vcell
%
% Inputs:
%   cellVoltage : Cell terminal voltage (V)
%   Pack        : Battery pack structure
%
% Output:
%   Vpack       : Pack voltage (V)
%===========================================================

Vpack = cellVoltage * Pack.Ns;

end