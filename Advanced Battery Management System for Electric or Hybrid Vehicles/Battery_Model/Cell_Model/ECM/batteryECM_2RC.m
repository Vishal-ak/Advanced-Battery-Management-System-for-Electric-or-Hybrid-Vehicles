function [Vt,Vrc1_new,Vrc2_new,OCV,Status] = batteryECM_2RC(SOC,current,Vrc1_old,Vrc2_old,dt,Battery)
%BATTERYECM_2RC Second-order Thevenin ECM voltage prediction.
% Positive current denotes discharge; negative current denotes charging.
% The output voltage is not clipped. The 2RC branch parameters require
% identification against cell pulse/dynamic data before predictive use.

if nargin ~= 6 || ~isstruct(Battery) || ~isscalar(Battery)
    error('BMS:InvalidECMInput','Six inputs including Battery are required.');
end
inputs = {SOC,current,Vrc1_old,Vrc2_old,dt};
validScalars = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(validScalars) || dt <= 0
    error('BMS:InvalidECMInput', ...
        'All state, current and time inputs must be finite real scalars; dt must be positive.');
end
if SOC < 0 || SOC > 1
    error('BMS:InvalidSOC','SOC must be in [0,1].');
end

required = {'SOC_Table','OCV_Table','R0','R1','C1','R2','C2', ...
    'MaximumVoltage','CutoffVoltage'};
for k = 1:numel(required)
    if ~isfield(Battery,required{k})
        error('BMS:MissingECMParameter','Battery.%s is required.',required{k});
    end
end

socTable = Battery.SOC_Table;
ocvTable = Battery.OCV_Table;
if ~isnumeric(socTable) || ~isreal(socTable) || ~isvector(socTable) || ...
        numel(socTable) < 2 || ~isnumeric(ocvTable) || ~isreal(ocvTable) || ...
        ~isvector(ocvTable) || numel(ocvTable) ~= numel(socTable) || ...
        any(~isfinite(socTable(:))) || any(~isfinite(ocvTable(:))) || ...
        any(diff(socTable(:)) <= 0)
    error('BMS:InvalidOCVTable', ...
        'SOC_Table and OCV_Table must be finite, equal-length vectors with strictly increasing SOC.');
end
positiveParams = {'R0','R1','C1','R2','C2'};
for k = 1:numel(positiveParams)
    name = positiveParams{k};
    value = Battery.(name);
    if ~isnumeric(value) || ~isreal(value) || ~isscalar(value) || ...
            ~isfinite(value) || value <= 0
        error('BMS:InvalidECMParameter','Battery.%s must be a positive finite scalar.',name);
    end
end
if ~isnumeric(Battery.CutoffVoltage) || ~isnumeric(Battery.MaximumVoltage) || ...
        ~isscalar(Battery.CutoffVoltage) || ~isscalar(Battery.MaximumVoltage) || ...
        ~isfinite(Battery.CutoffVoltage) || ~isfinite(Battery.MaximumVoltage) || ...
        Battery.CutoffVoltage <= 0 || Battery.MaximumVoltage <= Battery.CutoffVoltage
    error('BMS:InvalidECMParameter','Cell voltage limits are invalid.');
end

OCV = interp1(socTable(:),ocvTable(:),SOC,'linear','extrap');
[Vrc1_new,Vrc2_new] = updateRCVoltage_2RC( ...
    Vrc1_old,Vrc2_old,current,dt,Battery.R1,Battery.C1,Battery.R2,Battery.C2);
Vt = terminalVoltage_2RC(OCV,current,Battery.R0,Vrc1_new,Vrc2_new);

Status.OverVoltage = Vt > Battery.MaximumVoltage;
Status.UnderVoltage = Vt < Battery.CutoffVoltage;
Status.WithinVoltageLimits = ~(Status.OverVoltage || Status.UnderVoltage);
Status.OCVOutsideDataRange = SOC < min(socTable) || SOC > max(socTable);
end
