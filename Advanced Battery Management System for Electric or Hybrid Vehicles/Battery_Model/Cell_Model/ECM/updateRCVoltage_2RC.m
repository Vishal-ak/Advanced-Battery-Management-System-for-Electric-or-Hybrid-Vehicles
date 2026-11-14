function [Vrc1_new, Vrc2_new] = updateRCVoltage_2RC(Vrc1_old, Vrc2_old, current, dt, R1, C1, R2, C2)
%UPDATERCVOLTAGE_2RC Exact-ZOH update of two Thevenin polarization branches.
% Positive current denotes discharge. Current is assumed constant over dt.

values = [Vrc1_old, Vrc2_old, current, dt, R1, C1, R2, C2];
if ~isnumeric(values) || ~isreal(values) || any(~isfinite(values)) || ...
        any([numel(Vrc1_old), numel(Vrc2_old), numel(current), numel(dt), ...
             numel(R1), numel(C1), numel(R2), numel(C2)] ~= 1)
    error('BMS:InvalidECMInput', 'All inputs must be finite real scalars.');
end
if dt <= 0
    error('BMS:InvalidECMInput', 'The timestep dt must be positive.');
end
if any([R1, C1, R2, C2] <= 0)
    error('BMS:InvalidECMParameter', 'Both RC branch resistances and capacitances must be positive.');
end

alpha1 = exp(-dt / (R1 * C1));
alpha2 = exp(-dt / (R2 * C2));

Vrc1_new = alpha1 * Vrc1_old + R1 * (1 - alpha1) * current;
Vrc2_new = alpha2 * Vrc2_old + R2 * (1 - alpha2) * current;
end
