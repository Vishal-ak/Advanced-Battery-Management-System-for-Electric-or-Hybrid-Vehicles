function [Vrc1_new,Vrc2_new] = updateRCVoltage_2RC(Vrc1_old,Vrc2_old,current,dt,R1,C1,R2,C2)
%UPDATERCVOLTAGE_2RC Exact zero-order-hold update of two polarization branches.
% Positive current denotes discharge. Units: V, A, s, ohm and F.
values = [Vrc1_old,Vrc2_old,current,dt,R1,C1,R2,C2];
if any(~isfinite(values)) || dt <= 0 || R1 <= 0 || C1 <= 0 || R2 <= 0 || C2 <= 0
    error('BMS:Invalid2RCInput','Inputs must be finite scalars; dt, R1, C1, R2 and C2 must be positive.');
end
a1 = exp(-dt/(R1*C1));
a2 = exp(-dt/(R2*C2));
Vrc1_new = a1*Vrc1_old + R1*(1-a1)*current;
Vrc2_new = a2*Vrc2_old + R2*(1-a2)*current;
end
