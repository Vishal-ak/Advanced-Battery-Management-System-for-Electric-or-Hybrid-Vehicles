function [Vt, Status] = terminalVoltage_2RC(OCV, current, R0, Vrc1, Vrc2, cutoffVoltage, maximumVoltage)
%TERMINALVOLTAGE_2RC Calculate unconstrained 2RC terminal voltage.
% Positive current denotes discharge. Voltage is deliberately not clipped.

values = [OCV, current, R0, Vrc1, Vrc2, cutoffVoltage, maximumVoltage];
if ~isnumeric(values) || ~isreal(values) || any(~isfinite(values)) || ...
        any([numel(OCV), numel(current), numel(R0), numel(Vrc1), ...
             numel(Vrc2), numel(cutoffVoltage), numel(maximumVoltage)] ~= 1)
    error('BMS:InvalidECMInput', 'All terminal-voltage inputs must be finite real scalars.');
end
if R0 <= 0 || cutoffVoltage >= maximumVoltage
    error('BMS:InvalidECMParameter', 'R0 must be positive and cutoff voltage must be below maximum voltage.');
end

Vt = OCV - current * R0 - Vrc1 - Vrc2;
Status.OverVoltage = Vt > maximumVoltage;
Status.UnderVoltage = Vt < cutoffVoltage;
Status.WithinVoltageLimits = ~(Status.OverVoltage || Status.UnderVoltage);
end
