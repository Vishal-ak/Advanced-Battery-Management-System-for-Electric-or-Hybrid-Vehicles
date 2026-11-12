function Vt = terminalVoltage_2RC(OCV,current,R0,Vrc1,Vrc2)
%TERMINALVOLTAGE_2RC Terminal voltage of a second-order Thevenin ECM.
% Positive current denotes discharge. Voltage is not clipped; the calling
% supervisory layer must handle any reported voltage-limit violation.
values = [OCV,current,R0,Vrc1,Vrc2];
if any(~isfinite(values)) || R0 < 0
    error('BMS:Invalid2RCInput','Inputs must be finite scalars and R0 must be nonnegative.');
end
Vt = OCV - current*R0 - Vrc1 - Vrc2;
end
