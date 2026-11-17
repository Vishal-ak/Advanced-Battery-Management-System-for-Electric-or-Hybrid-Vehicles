function SOC_new = coulombCounting(SOC_old,current,dt,capacity_Ah)
%COULOMBCOUNTING Integrate cell current to update state of charge.
% Sign convention: positive current is discharge; negative is charging.
% Inputs: SOC_old [0..1], current [A], dt [s], capacity_Ah [Ah].
% This implementation does not include efficiency, sensor bias or aging.

inputs = {SOC_old,current,dt,capacity_Ah};
validScalars = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(validScalars)
    error('BMS:InvalidSOCInput', ...
        'SOC, current, dt and capacity must be finite real numeric scalars.');
end
if SOC_old < 0 || SOC_old > 1
    error('BMS:InvalidSOC','SOC_old must be in [0,1].');
end
if dt <= 0
    error('BMS:InvalidTimeStep','dt must be positive and expressed in seconds.');
end
if capacity_Ah <= 0
    error('BMS:InvalidCapacity','capacity_Ah must be positive.');
end

capacity_C = capacity_Ah*3600;
SOC_new = SOC_old - (current*dt)/capacity_C;
SOC_new = max(0,min(1,SOC_new));
end
