function Vrc_new = updateRCVoltage(Vrc_old,current,dt,R1,C1)
%===========================================================
% UPDATE RC BRANCH VOLTAGE
%
% Calculates the RC polarization voltage
%
% Inputs:
%   Vrc_old   Previous RC voltage (V)
%   current   Battery current (+ discharge) (A)
%   dt        Time step (s)
%   R1        Polarization resistance (Ohm)
%   C1        Polarization capacitance (F)
%
% Output:
%   Vrc_new   Updated RC voltage (V)
%===========================================================

tau = R1*C1;

alpha = exp(-dt/tau);

Vrc_new = alpha*Vrc_old + R1*(1-alpha)*current;

end