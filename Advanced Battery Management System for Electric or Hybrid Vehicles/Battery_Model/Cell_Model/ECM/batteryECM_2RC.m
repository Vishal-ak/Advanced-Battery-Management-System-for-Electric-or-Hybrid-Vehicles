function [Vt,Vrc1_new,Vrc2_new,OCV,Status] = batteryECM_2RC(SOC,current,Vrc1_old,Vrc2_old,dt,Battery)
%BATTERYECM_2RC Second-order Thevenin ECM voltage prediction.
% Positive current denotes discharge; negative current denotes charging.
% Vt is not clamped; Status exposes cell-voltage limit violations.
if nargin ~= 6 || ~isstruct(Battery)
    error('BMS:InvalidECMInput','Six inputs including Battery are required.');
end
values = [SOC,current,Vrc1_old,Vrc2_old,dt];
if any(~isfinite(values)) || dt <= 0 || SOC < 0 || SOC > 1
    error('BMS:InvalidECMInput','Inputs must be finite; dt>0 and SOC in [0,1].');
end
required = {'SOC_Table','OCV_Table','R0','R1','C1','R2','C2','MaximumVoltage','CutoffVoltage'};
for k = 1:numel(required)
    if ~isfield(Battery,required{k}), error('BMS:MissingECMParameter','Battery.%s is required.',required{k}); end
end
OCV = interp1(Battery.SOC_Table,Battery.OCV_Table,SOC,'linear','extrap');
[Vrc1_new,Vrc2_new] = updateRCVoltage_2RC(Vrc1_old,Vrc2_old,current,dt,Battery.R1,Battery.C1,Battery.R2,Battery.C2);
Vt = terminalVoltage_2RC(OCV,current,Battery.R0,Vrc1_new,Vrc2_new);
Status.OverVoltage = Vt > Battery.MaximumVoltage;
Status.UnderVoltage = Vt < Battery.CutoffVoltage;
Status.WithinVoltageLimits = ~(Status.OverVoltage || Status.UnderVoltage);
Status.OCVOutsideDataRange = SOC < min(Battery.SOC_Table) || SOC > max(Battery.SOC_Table);
end