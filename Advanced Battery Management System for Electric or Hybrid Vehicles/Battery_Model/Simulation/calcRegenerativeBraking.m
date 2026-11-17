function [I_regen,eta_regen] = calcRegenerativeBraking(P_brake_req,PackVoltage,PackSOC,CellTemp,Pack)
%CALCREGENERATIVEBRAKING Estimate a simplified allowable regen charging current.
% Negative I_regen denotes charging. This is not a cell charge-acceptance model.
% Below the cell datasheet's 10 degC threshold, use the 0.25C current limit.

if nargin ~= 5 || ~isstruct(Pack) || ~isscalar(Pack)
    error('BMS:InvalidRegenInput','Five inputs including scalar Pack are required.');
end
inputs = {P_brake_req,PackVoltage,PackSOC,CellTemp};
validScalars = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(validScalars) || PackVoltage <= 0 || PackSOC < 0 || PackSOC > 1
    error('BMS:InvalidRegenInput', ...
        'Power, voltage, temperature and SOC must be finite real scalars; voltage > 0 and SOC in [0,1].');
end
if P_brake_req >= 0
    I_regen = 0;
    eta_regen = 0;
    return;
end

required = {'CutoffVoltage','MaximumVoltage','R0', ...
    'StandardChargeCurrent','MinChargeTemperature','MaxChargeTemperature', ...
    'LowTempChargeTemperatureThreshold','LowTempChargeCurrent'};
for k = 1:numel(required)
    if ~isfield(Pack,required{k})
        error('BMS:MissingRegenParameter','Pack.%s is required.',required{k});
    end
end
if CellTemp < Pack.MinChargeTemperature || CellTemp > Pack.MaxChargeTemperature
    I_regen = 0;
    eta_regen = 0;
    return;
end

% SOC derating is a project heuristic and requires validation before use.
if PackSOC >= 0.95
    f_soc = 0;
elseif PackSOC > 0.85
    f_soc = (0.95-PackSOC)/0.10;
else
    f_soc = 1;
end
eta_base = 0.92*0.88;
eta_regen = eta_base*f_soc;
P_regen_elec = P_brake_req*eta_regen;
V_safe = max(PackVoltage,Pack.CutoffVoltage);
I_req = P_regen_elec/V_safe;

if CellTemp < Pack.LowTempChargeTemperatureThreshold
    I_max_charge = Pack.LowTempChargeCurrent; % Pack-level 0.25C limit
else
    I_max_charge = Pack.StandardChargeCurrent; % Pack-level standard charge limit
end
voltageHeadroom = max(0,(Pack.MaximumVoltage-PackVoltage)/max(Pack.R0,1e-6));
I_limit = min(I_max_charge,voltageHeadroom);
I_regen = max(I_req,-I_limit);
end
