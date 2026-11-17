function [Vt,Vrc_new,OCV,Status] = batteryECM(SOC,current,Vrc_old,dt,Battery)
%BATTERYECM First-order Thevenin ECM voltage prediction.
% Positive current is discharge; negative current is charging.
% The returned voltage is not clipped to limits; inspect Status.

if nargin ~= 5 || ~isstruct(Battery) || ~isscalar(Battery)
    error('BMS:InvalidECMInput', ...
        'Usage: batteryECM(SOC,current,Vrc_old,dt,Battery).');
end
inputs = {SOC,current,Vrc_old,dt};
validScalars = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v), inputs);
if ~all(validScalars) || dt <= 0
    error('BMS:InvalidECMInput', ...
        'SOC, current, Vrc_old and dt must be finite real scalars; dt must be positive.');
end
if SOC < 0 || SOC > 1
    error('BMS:InvalidSOC','SOC must be in [0,1].');
end

required = {'SOC_Table','OCV_Table','R0','R1','C1', ...
    'MaximumVoltage','CutoffVoltage'};
for k = 1:numel(required)
    if ~isfield(Battery,required{k})
        error('BMS:MissingECMParameter','Battery.%s is required.',required{k});
    end
end

% Validate the lookup table rather than silently accepting malformed data.
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

positiveParams = {'R0','R1','C1'};
for k = 1:numel(positiveParams)
    name = positiveParams{k};
    value = Battery.(name);
    if ~isnumeric(value) || ~isreal(value) || ~isscalar(value) || ...
            ~isfinite(value) || value <= 0
        error('BMS:InvalidECMParameter','Battery.%s must be a positive finite scalar.',name);
    end
end
limits = [Battery.CutoffVoltage,Battery.MaximumVoltage];
if ~isnumeric(limits) || ~isreal(limits) || any(~isfinite(limits)) || ...
        Battery.CutoffVoltage <= 0 || Battery.MaximumVoltage <= Battery.CutoffVoltage
    error('BMS:InvalidECMParameter', ...
        'CutoffVoltage and MaximumVoltage must be finite, positive and correctly ordered.');
end

OCV = interp1(socTable(:),ocvTable(:),SOC,'linear','extrap');
Vrc_new = updateRCVoltage(Vrc_old,current,dt,Battery.R1,Battery.C1);
Vt = terminalVoltage(OCV,current,Battery.R0,Vrc_new);

Status.OverVoltage = Vt > Battery.MaximumVoltage;
Status.UnderVoltage = Vt < Battery.CutoffVoltage;
Status.WithinVoltageLimits = ~(Status.OverVoltage || Status.UnderVoltage);
Status.OCVOutsideDataRange = SOC < min(socTable) || SOC > max(socTable);
end
