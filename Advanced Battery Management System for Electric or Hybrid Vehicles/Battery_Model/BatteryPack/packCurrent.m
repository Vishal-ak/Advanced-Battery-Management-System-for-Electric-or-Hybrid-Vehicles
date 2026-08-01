function Ipack = packCurrent(cellCurrent, Pack)
%===========================================================
% packCurrent.m
%
% Calculates battery pack current.
%
% Equation:
% Ipack = Np × Icell
%
%===========================================================

Ipack = cellCurrent * Pack.Np;

end