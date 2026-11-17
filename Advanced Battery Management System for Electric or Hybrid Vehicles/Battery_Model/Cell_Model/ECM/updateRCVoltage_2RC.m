function [Vrc1_new,Vrc2_new] = updateRCVoltage_2RC(Vrc1_old,Vrc2_old,current,dt,R1,C1,R2,C2)
%UPDATERCVOLTAGE_2RC Exact zero-order-hold update for two RC branches.
% Positive current is discharge. Units: V, A, s, ohm and farad.

inputs = {Vrc1_old,Vrc2_old,current,dt,R1,C1,R2,C2};
validScalars = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(validScalars)
    error('BMS:InvalidRCInput','All 2RC inputs must be finite real numeric scalars.');
end
if dt <= 0 || R1 <= 0 || C1 <= 0 || R2 <= 0 || C2 <= 0
    error('BMS:InvalidRCParameter','dt, R1, C1, R2 and C2 must be positive.');
end

alpha1 = exp(-dt/(R1*C1));
alpha2 = exp(-dt/(R2*C2));
Vrc1_new = alpha1*Vrc1_old + R1*(1-alpha1)*current;
Vrc2_new = alpha2*Vrc2_old + R2*(1-alpha2)*current;
end
