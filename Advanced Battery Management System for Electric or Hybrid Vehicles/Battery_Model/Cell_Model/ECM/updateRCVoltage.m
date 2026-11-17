function Vrc_new = updateRCVoltage(Vrc_old,current,dt,R1,C1)
%UPDATERCVOLTAGE Exact zero-order-hold update of one RC polarization branch.
% Positive current is discharge. Units: V, A, s, ohm and farad.

inputs = {Vrc_old,current,dt,R1,C1};
validScalars = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(validScalars)
    error('BMS:InvalidRCInput','All RC inputs must be finite real numeric scalars.');
end
if dt <= 0 || R1 <= 0 || C1 <= 0
    error('BMS:InvalidRCParameter','dt, R1 and C1 must be positive.');
end

alpha = exp(-dt/(R1*C1));
Vrc_new = alpha*Vrc_old + R1*(1-alpha)*current;
end
