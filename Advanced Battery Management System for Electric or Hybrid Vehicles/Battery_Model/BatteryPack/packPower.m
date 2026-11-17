function Power = packPower(packVoltage,packCurrent)
%PACKPOWER Calculate electrical pack power in watts.

inputs = {packVoltage,packCurrent};
valid = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(valid)
    error('BMS:InvalidPackPowerInput', ...
        'Pack voltage and current must be finite real numeric scalars.');
end
if packVoltage < 0
    error('BMS:InvalidPackPowerInput','Pack voltage cannot be negative.');
end
Power = packVoltage*packCurrent;
end
