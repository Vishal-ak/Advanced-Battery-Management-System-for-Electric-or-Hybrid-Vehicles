function Vpack = packVoltage(cellVoltage,Pack)
%PACKVOLTAGE Calculate pack voltage for a series-connected cell string.

if ~isnumeric(cellVoltage) || ~isreal(cellVoltage) || ...
        ~isscalar(cellVoltage) || ~isfinite(cellVoltage)
    error('BMS:InvalidPackVoltageInput','cellVoltage must be a finite real scalar.');
end
if ~isstruct(Pack) || ~isscalar(Pack) || ~isfield(Pack,'Ns') || ...
        ~isnumeric(Pack.Ns) || ~isreal(Pack.Ns) || ...
        ~isscalar(Pack.Ns) || ~isfinite(Pack.Ns) || ...
        Pack.Ns < 1 || fix(Pack.Ns) ~= Pack.Ns
    error('BMS:InvalidPackConfiguration','Pack.Ns must be a positive integer.');
end
Vpack = cellVoltage*Pack.Ns;
end
