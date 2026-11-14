function [Vt,Vrc1_new,Vrc2_new,OCV,Status] = batteryECM_2RC(SOC,current,Vrc1_old,Vrc2_old,dt,Battery)
%BATTERYECM_2RC Second-order Thevenin ECM voltage prediction.
% Positive current denotes discharge; negative current denotes charging.
% Vt is not clamped; Status exposes cell-voltage limit violations.

if nargin ~= 6 || ~isstruct(Battery)
    error('BMS:InvalidECMInput','Six inputs including Battery are required.');
end
inputs = {SOC,current,Vrc1_old,Vrc2_old,dt};
for k = 1:numel(inputs)
    x = inputs{k};
    if ~isnumeric(x) || ~isreal(x) || ~isscalar(x) || ~isfinite(x)
        error('BMS:InvalidECMInput','All operating inputs must be finite real scalars.');
    end
end
if dt <= 0
    error('BMS:InvalidECMInput','dt must be positive.');
end
if SOC < 0 || SOC > 1
    error('BMS:InvalidSOC','SOC must be in [0,1].');
end

required = {'SOC_Table','OCV_Table','R0','R1','C1','R2','C2','MaximumVoltage','CutoffVoltage'};
for k = 1:numel(required)
    if ~isfield(Battery,required{k})
        error('BMS:MissingECMParameter','Battery.%s is required.',required{k});
    end
end
parameterNames = {'R0','R1','C1','R2','C2','MaximumVoltage','CutoffVoltage'};
for k = 1:numel(parameterNames)
    value = Battery.(parameterNames{k});
    if ~isnumeric(value) || ~isreal(value) || ~isscalar(value) || ~isfinite(value)
        error('BMS:InvalidECMParameter','Battery.%s must be a finite real scalar.',parameterNames{k});
    end
end
if any([Battery.R0,Battery.R1,Battery.C1,Battery.R2,Battery.C2] <= 0) || ...
        Battery.CutoffVoltage >= Battery.MaximumVoltage
    error('BMS:InvalidECMParameter','R/C values must be positive and cutoff voltage below maximum voltage.');
end

socTable = Battery.SOC_Table(:);
ocvTable = Battery.OCV_Table(:);
if numel(socTable) < 2 || numel(socTable) ~= numel(ocvTable) || ...
        ~isnumeric(socTable) || ~isnumeric(ocvTable) || ...
        ~isreal(socTable) || ~isreal(ocvTable) || ...
        any(~isfinite(socTable)) || any(~isfinite(ocvTable)) || ...
        any(diff(socTable) <= 0)
    error('BMS:InvalidOCVTable','SOC/OCV tables must be finite, equal-length vectors with strictly increasing SOC.');
end

OCV = interp1(socTable,ocvTable,SOC,'linear','extrap');
[Vrc1_new,Vrc2_new] = updateRCVoltage_2RC( ...
    Vrc1_old,Vrc2_old,current,dt,Battery.R1,Battery.C1,Battery.R2,Battery.C2);
Vt = terminalVoltage_2RC(OCV,current,Battery.R0,Vrc1_new,Vrc2_new);

Status.OverVoltage = Vt > Battery.MaximumVoltage;
Status.UnderVoltage = Vt < Battery.CutoffVoltage;
Status.WithinVoltageLimits = ~(Status.OverVoltage || Status.UnderVoltage);
Status.OCVOutsideDataRange = SOC < min(socTable) || SOC > max(socTable);
end
