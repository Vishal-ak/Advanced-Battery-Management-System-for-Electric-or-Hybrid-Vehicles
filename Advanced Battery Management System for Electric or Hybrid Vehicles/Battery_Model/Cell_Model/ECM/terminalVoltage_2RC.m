function Vt = terminalVoltage_2RC(OCV,current,R0,Vrc1,Vrc2)
%TERMINALVOLTAGE_2RC Calculate terminal voltage for a 2RC Thevenin ECM.
% Positive current denotes discharge; output is not clipped to voltage limits.

inputs = {OCV,current,R0,Vrc1,Vrc2};
validScalars = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(validScalars)
    error('BMS:InvalidTerminalVoltageInput', ...
        'All terminal-voltage inputs must be finite real numeric scalars.');
end
if R0 <= 0
    error('BMS:InvalidECMParameter','R0 must be positive.');
end
Vt = OCV - current*R0 - Vrc1 - Vrc2;
end
