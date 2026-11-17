function T_new = updateTemperature(T_old,Heat,T_ambient,dt,Battery)
%UPDATETEMPERATURE Advance a single-node cell thermal model with Euler integration.
% Temperatures are in degC, Heat in W, dt in seconds.

inputs = {T_old,Heat,T_ambient,dt};
valid = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(valid)
    error('BMS:InvalidThermalInput', ...
        'Temperature, heat and time-step inputs must be finite real scalars.');
end
if dt <= 0 || Heat < 0
    error('BMS:InvalidThermalInput','dt must be positive and ohmic heat must be nonnegative.');
end
if ~isstruct(Battery) || ~isscalar(Battery)
    error('BMS:InvalidThermalParameters','Battery must be a scalar structure.');
end
required = {'Mass','SpecificHeat','ThermalResistance'};
for k = 1:numel(required)
    f = required{k};
    if ~isfield(Battery,f) || ~isnumeric(Battery.(f)) || ...
            ~isreal(Battery.(f)) || ~isscalar(Battery.(f)) || ...
            ~isfinite(Battery.(f)) || Battery.(f) <= 0
        error('BMS:InvalidThermalParameters', ...
            'Battery.%s must be a positive finite real scalar.',f);
    end
end

m = Battery.Mass;
Cp = Battery.SpecificHeat;
Rth = Battery.ThermalResistance;
Cooling = (T_old-T_ambient)/Rth;
dTdt = (Heat-Cooling)/(m*Cp);
T_new = T_old+dTdt*dt;
end
