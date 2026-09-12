function Vt = terminalVoltage(OCV,current,R0,Vrc)
%===========================================================
% TERMINAL VOLTAGE
%
% Calculates battery terminal voltage.
%
% Inputs
%   OCV
%   current
%   R0
%   Vrc
%
% Output
%   Vt
%===========================================================

Vt = OCV - current*R0 - Vrc;

end