function [I_regen,eta_regen] = calcRegenerativeBraking(P_brake_req,PackVoltage,PackSOC,CellTemp,Pack)
%CALCREGENERATIVEBRAKING Estimate allowable regenerative charging current.
% Negative I_regen denotes charging. This is a simplified supervisor, not
% a validated electrochemical charge-acceptance or lithium-plating model.

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

eta_base = 0.92*0.88;
if PackSOC >= 0.95
    f_soc = 0;
elseif PackSOC > 0.85
    f_soc = (0.95-PackSOC)/0.10;
else
    f_soc = 1;
end

% Use cell-specific charge-temperature bounds propagated into Pack.
if isfield(Pack,'MinChargeTemperature')
    Tmin = Pack.MinChargeTemperature;
else
    Tmin = 0; % Conservative datasheet-based fallback for NCR18650B
end
if isfield(Pack,'MaxChargeTemperature')
    Tmax = Pack.MaxChargeTemperature;
else
    Tmax = 45; % Datasheet charge ambient upper bound for NCR18650B
end
if ~isnumeric(Tmin) || ~isscalar(Tmin) || ~isfinite(Tmin) || ...
        ~isnumeric(Tmax) || ~isscalar(Tmax) || ~isfinite(Tmax) || Tmin >= Tmax
    error('BMS:InvalidChargeTemperatureLimits', ...
        'Pack charge-temperature limits must be finite ordered scalars.');
end

if CellTemp <= Tmin || CellTemp >= Tmax
    f_temp = 0;
elseif CellTemp < Tmin+10
    f_temp = (CellTemp-Tmin)/10;
elseif CellTemp > Tmax-5
    f_temp = (Tmax-CellTemp)/5;
else
    f_temp = 1;
end

eta_regen = eta_base*f_soc*f_temp;
P_regen_elec = P_brake_req*eta_regen;
V_safe = max(PackVoltage,Pack.CutoffVoltage);
I_req = P_regen_elec/V_safe;

if isfield(Pack,'MaxChargeCurrent')
    I_max_charge = Pack.MaxChargeCurrent;
elseif isfield(Pack,'StandardChargeCurrent')
    I_max_charge = Pack.StandardChargeCurrent;
else
    error('BMS:MissingChargeLimit','Pack must define a charge-current limit.');
end
if isfield(Pack,'MaximumVoltage') && isfield(Pack,'R0')
    voltageHeadroom = max(0,(Pack.MaximumVoltage-PackVoltage)/max(Pack.R0,1e-6));
else
    voltageHeadroom = I_max_charge;
end
I_limit = min(I_max_charge,voltageHeadroom);
I_regen = max(I_req,-I_limit);
end
