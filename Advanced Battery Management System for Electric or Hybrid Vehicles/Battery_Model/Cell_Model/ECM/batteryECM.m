function [Vt,Vrc_new,OCV,Status] = batteryECM(SOC,current,Vrc_old,dt,Battery)
%BATTERYECM First-order Thevenin ECM voltage prediction.
% Positive current is discharge; negative current is charging.
% Vt is the unconstrained physical model prediction, not a clipped value.
% A supervisory BMS must act on any reported voltage-limit violation.

if nargin~=5 || ~isstruct(Battery)
    error('BMS:InvalidECMInput','Usage: batteryECM(SOC,current,Vrc_old,dt,Battery)');
end
x=[SOC,current,Vrc_old,dt];
if any(~isfinite(x)) || any(cellfun(@(v) ~isscalar(v),{SOC,current,Vrc_old,dt})) || dt<=0
    error('BMS:InvalidECMInput','Inputs must be finite scalars and dt must be positive.');
end
if SOC<0 || SOC>1, error('BMS:InvalidSOC','SOC must be in [0,1].'); end
required={'SOC_Table','OCV_Table','R0','R1','C1','MaximumVoltage','CutoffVoltage'};
for k=1:numel(required)
    if ~isfield(Battery,required{k}), error('BMS:MissingECMParameter','Battery.%s is required.',required{k}); end
end
if Battery.R0<=0 || Battery.R1<=0 || Battery.C1<=0
    error('BMS:InvalidECMParameter','R0, R1 and C1 must be positive.');
end
OCV=interp1(Battery.SOC_Table,Battery.OCV_Table,SOC,'linear','extrap');
Vrc_new=updateRCVoltage(Vrc_old,current,dt,Battery.R1,Battery.C1);
Vt=terminalVoltage(OCV,current,Battery.R0,Vrc_new);
Status.OverVoltage=Vt>Battery.MaximumVoltage;
Status.UnderVoltage=Vt<Battery.CutoffVoltage;
Status.WithinVoltageLimits=~Status.OverVoltage && ~Status.UnderVoltage;
Status.OCVOutsideDataRange=SOC<min(Battery.SOC_Table) || SOC>max(Battery.SOC_Table);
end