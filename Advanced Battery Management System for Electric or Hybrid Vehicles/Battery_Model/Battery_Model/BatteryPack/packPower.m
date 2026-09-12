function Power = packPower(packVoltage, packCurrent)
%===========================================================
% packPower.m
%
% Calculates battery pack power.
%
% Equation:
% P = V × I
%
%===========================================================

Power = packVoltage * packCurrent;

end