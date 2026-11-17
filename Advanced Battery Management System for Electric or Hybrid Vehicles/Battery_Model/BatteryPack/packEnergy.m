function [Energy_Wh,Energy_kWh] = packEnergy(packVoltage,capacity)
%PACKENERGY Calculate nominal pack energy from voltage (V) and capacity (Ah).

inputs = {packVoltage,capacity};
valid = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(valid) || packVoltage <= 0 || capacity <= 0
    error('BMS:InvalidPackEnergyInput', ...
        'Pack voltage and capacity must be positive finite real scalars.');
end
Energy_Wh = packVoltage*capacity;
Energy_kWh = Energy_Wh/1000;
end
