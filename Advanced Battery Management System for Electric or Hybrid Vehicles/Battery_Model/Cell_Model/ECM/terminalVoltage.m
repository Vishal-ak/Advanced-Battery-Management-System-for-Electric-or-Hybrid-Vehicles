function Vt = terminalVoltage(OCV,current,R0,Vrc)
%TERMINALVOLTAGE Calculate 1RC Thevenin terminal voltage.
% Positive current denotes discharge; voltage is not clipped to limits.

inputs = {OCV,current,R0,Vrc};
valid = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(valid)
    error('BMS:InvalidTerminalVoltageInput', ...
        'OCV, current, R0 and Vrc must be finite real numeric scalars.');
end
if R0 <= 0
    error('BMS:InvalidECMParameter','R0 must be positive.');
end
Vt = OCV-current*R0-Vrc;
end
