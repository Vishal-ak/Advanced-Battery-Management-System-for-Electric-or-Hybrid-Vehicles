function [Vt,Vrc_new,OCV,Status] = batteryECM(SOC,current,Vrc_old,dt,Battery)
%BATTERYECM First-order Thevenin ECM voltage prediction.
% Positive current denotes discharge; negative current denotes charge.
% Vt is deliberately not clamped: the caller must apply BMS protection.

if nargin ~= 5 || ~isstruct(Battery)
    error('BMS:InvalidECMInput', ...
        'Usage: batteryECM(SOC,current,Vrc_old,dt,Battery)');
end
if ~isscalar(SOC) || ~isscalar(current) || ~isscalar(Vrc_old) || ...
        ~isscalar(dt) || any(~isfinite([SOC,current,Vrc_old,dt])) || dt <= 0
    error('BMS:InvalidECMInput', ...
        'SOC, current and Vrc_old must be finite scalars; dt must be positive.');
end
if SOC < 0 || SOC > 1
    error('BMS:InvalidSOC','SOC must be within [0,1].');
end
required = {'SOC_Table','OCV_Table','R0','R1','C1', ...
    'MaximumVoltage','CutoffVoltage'};
for k = 1:numel(required)
    if ~isfield(Battery,required{k})
        error('BMS:MissingECMParameter','Battery.%s is required.',required{k});
    end
end
if Battery.R0 <= 0 || Battery.R1 <= 0 || Battery.C1 <= 0
    error('BMS:InvalidECMParameter','R0, R1 and C1 must be positive.');
end

OCV = interp1(Battery.SOC_Table,Battery.OCV_Table,SOC,'linear','extrap');
Vrc_new = updateRCVoltage(Vrc_old,current,dt,Battery.R1,Battery.C1);
Vt = terminalVoltage(OCV,current,Battery.R0,Vrc_new);

Status.OverVoltage = Vt > Battery.MaximumVoltage;
Status.UnderVoltage = Vt < Battery.CutoffVoltage;
Status.WithinVoltageLimits = ~(Status.OverVoltage || Status.UnderVoltage);
Status.OCVOutsideDataRange = SOC < min(Battery.SOC_Table) || ...
    SOC > max(Battery.SOC_Table);
end