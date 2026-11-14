function Vt = terminalVoltage_2RC(OCV, current, R0, Vrc1, Vrc2)
%TERMINALVOLTAGE_2RC Calculate unconstrained 2RC terminal voltage.
% Positive current denotes discharge. Voltage is deliberately not clipped.

values = [OCV, current, R0, Vrc1, Vrc2];
if ~isnumeric(values) || ~isreal(values) || ...
        any([numel(OCV), numel(current), numel(R0), numel(Vrc1), numel(Vrc2)] ~= 1) || ...
        any(~isfinite(values))
    error('BMS:InvalidECMInput', 'All inputs must be finite real scalars.');
end
if R0 <= 0
    error('BMS:InvalidECMParameter', 'R0 must be positive.');
end

Vt = OCV - current * R0 - Vrc1 - Vrc2;
end
