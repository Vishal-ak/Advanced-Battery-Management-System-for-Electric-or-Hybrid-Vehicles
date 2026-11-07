function [I_regen,eta_regen] = calcRegenerativeBraking(P_brake_req,PackVoltage,PackSOC,CellTemp,Pack)
%CALCREGENERATIVEBRAKING Estimate allowable regenerative charging current.
% Negative I_regen denotes charging. This is a simplified supervisory limit,
% not a validated electrochemical charge-acceptance model.
if nargin ~= 5 || ~isstruct(Pack)
    error('BMS:InvalidRegenInput','Five inputs including Pack are required.');
end
if any(~isfinite([P_brake_req,PackVoltage,PackSOC,CellTemp])) || PackVoltage <= 0 || PackSOC < 0 || PackSOC > 1
    error('BMS:InvalidRegenInput','Power, voltage, temperature and SOC are invalid.');
end
if P_brake_req >= 0, I_regen = 0; eta_regen = 0; return; end
eta_base = 0.92*0.88;
if PackSOC >= 0.95, f_soc = 0;
elseif PackSOC > 0.85, f_soc = (0.95-PackSOC)/0.10;
else, f_soc = 1; end
if CellTemp <= 0 || CellTemp >= 55, f_temp = 0;
elseif CellTemp < 10, f_temp = CellTemp/10;
else, f_temp = 1; end
eta_regen = eta_base*f_soc*f_temp;
P_regen_elec = P_brake_req*eta_regen;
V_safe = max(PackVoltage,Pack.CutoffVoltage);
I_req = P_regen_elec/V_safe;
if isfield(Pack,'MaxChargeCurrent'), I_max_charge = Pack.MaxChargeCurrent;
elseif isfield(Pack,'StandardChargeCurrent'), I_max_charge = Pack.StandardChargeCurrent;
else, error('BMS:MissingChargeLimit','Pack must define a charge-current limit.'); end
if isfield(Pack,'MaximumVoltage') && isfield(Pack,'R0')
    voltageHeadroom = max(0,(Pack.MaximumVoltage-PackVoltage)/max(Pack.R0,1e-6));
else
    voltageHeadroom = I_max_charge;
end
I_limit = min(I_max_charge,voltageHeadroom);
I_regen = max(I_req,-I_limit);
end