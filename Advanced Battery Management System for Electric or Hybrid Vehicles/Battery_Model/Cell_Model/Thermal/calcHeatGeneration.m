function Heat = calcHeatGeneration(current,Battery)
%CALCHEATGENERATION Calculate single-cell irreversible ohmic heat, I^2*R0.
% Current is in amperes; output heat is in watts.

if ~isnumeric(current) || ~isreal(current) || ~isscalar(current) || ~isfinite(current)
    error('BMS:InvalidThermalInput','Current must be a finite real numeric scalar.');
end
if ~isstruct(Battery) || ~isscalar(Battery) || ~isfield(Battery,'R0')
    error('BMS:InvalidThermalParameters','Battery must define scalar R0.');
end
if ~isnumeric(Battery.R0) || ~isreal(Battery.R0) || ...
        ~isscalar(Battery.R0) || ~isfinite(Battery.R0) || Battery.R0 <= 0
    error('BMS:InvalidThermalParameters','Battery.R0 must be a positive finite real scalar.');
end

Heat = current^2*Battery.R0;
end
