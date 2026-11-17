function Ipack = packCurrent(cellCurrent,Pack)
%PACKCURRENT Calculate pack current from equal parallel cell currents.

if ~isnumeric(cellCurrent) || ~isreal(cellCurrent) || ...
        ~isscalar(cellCurrent) || ~isfinite(cellCurrent)
    error('BMS:InvalidPackCurrentInput','cellCurrent must be a finite real scalar.');
end
if ~isstruct(Pack) || ~isscalar(Pack) || ~isfield(Pack,'Np') || ...
        ~isnumeric(Pack.Np) || ~isreal(Pack.Np) || ...
        ~isscalar(Pack.Np) || ~isfinite(Pack.Np) || ...
        Pack.Np < 1 || fix(Pack.Np) ~= Pack.Np
    error('BMS:InvalidPackConfiguration','Pack.Np must be a positive integer.');
end
Ipack = cellCurrent*Pack.Np;
end
