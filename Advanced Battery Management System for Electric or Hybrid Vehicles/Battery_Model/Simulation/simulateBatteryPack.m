function Results = simulateBatteryPack(Battery,Pack,InitialSOC,InitialCellTemperature,AmbientTemperature,dt,Duration,ProfileName)
%SIMULATEBATTERYPACK Run the cell ECM/SOC/thermal models in a pack context.
% drive-cycle functions provide a reference pack-current shape. This function
% scales it to the configured per-cell charge/discharge current limits, then
% converts pack current to cell current using Np. It is an educational model,
% not a vehicle-validated drive-cycle simulation or safety controller.

if nargin ~= 8
    error('BMS:InvalidSimulationInputs', ...
        ['Usage: simulateBatteryPack(Battery,Pack,InitialSOC,' ...
         'InitialCellTemperature,AmbientTemperature,dt,Duration,ProfileName).']);
end
if ~isstruct(Battery) || ~isscalar(Battery) || ...
        ~isstruct(Pack) || ~isscalar(Pack)
    error('BMS:InvalidSimulationInputs','Battery and Pack must be scalar structures.');
end

numericInputs = {InitialSOC,InitialCellTemperature,AmbientTemperature,dt,Duration};
valid = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),numericInputs);
if ~all(valid)
    error('BMS:InvalidSimulationInputs','All simulation settings must be finite real scalars.');
end
if InitialSOC < Battery.MinimumSOC || InitialSOC > Battery.MaximumSOC
    error('BMS:InvalidInitialSOC', ...
        'InitialSOC must be within the configured operating window [%.3f, %.3f].', ...
        Battery.MinimumSOC,Battery.MaximumSOC);
end
if dt <= 0 || Duration <= 0
    error('BMS:InvalidSimulationTime','dt and Duration must be positive.');
end
steps = Duration/dt;
if abs(steps-round(steps)) > 1e-9*max(1,abs(steps))
    error('BMS:InvalidSimulationTime', ...
        'Duration must be an integer multiple of dt.');
end
requiredPack = {'Ns','Np','NominalVoltage','MaximumVoltage','CutoffVoltage', ...
    'MaxDischargeCurrent','StandardChargeCurrent'};
for k = 1:numel(requiredPack)
    if ~isfield(Pack,requiredPack{k})
        error('BMS:InvalidPack','Pack.%s is required.',requiredPack{k});
    end
end
if Pack.Ns < 1 || Pack.Np < 1 || fix(Pack.Ns) ~= Pack.Ns || ...
        fix(Pack.Np) ~= Pack.Np
    error('BMS:InvalidPack','Pack Ns and Np must be positive integers.');
end
profileNames = ["Synthetic drive cycle","Constant discharge","Constant charge", ...
    "Step discharge","Pulse discharge"];
profile = string(ProfileName);
if ~isscalar(profile) || ~any(profile == profileNames)
    error('BMS:InvalidCurrentProfile','Select a supported current profile.');
end

time = (0:round(steps))*dt;
switch profile
    case "Synthetic drive cycle"
        rawPackCurrent = driveCycleCurrent(time);
    case "Constant discharge"
        cellCurrent = Battery.MaxDischargeCurrent;
        rawPackCurrent = cellCurrent*Pack.Np*ones(size(time));
    case "Constant charge"
        cellCurrent = Battery.StandardChargeCurrent;
        rawPackCurrent = -cellCurrent*Pack.Np*ones(size(time));
    case "Step discharge"
        rawPackCurrent = stepCurrent(time);
    case "Pulse discharge"
        rawPackCurrent = pulseCurrent(time);
end

% Independently scale positive (discharge) and negative (charge) requests.
% No current command is allowed to exceed the configured project limits.
positivePeak = max([0,rawPackCurrent]);
negativePeak = max([0,-rawPackCurrent]);
dischargeScale = 1;
chargeScale = 1;
if positivePeak > 0
    dischargeScale = min(1,(Battery.MaxDischargeCurrent*Pack.Np)/positivePeak);
end
if negativePeak > 0
    chargeScale = min(1,(Battery.StandardChargeCurrent*Pack.Np)/negativePeak);
end
packCurrentCommand = rawPackCurrent;
packCurrentCommand(rawPackCurrent > 0) = ...
    rawPackCurrent(rawPackCurrent > 0)*dischargeScale;
packCurrentCommand(rawPackCurrent < 0) = ...
    rawPackCurrent(rawPackCurrent < 0)*chargeScale;

n = numel(time);
soc = zeros(1,n);
temperature = zeros(1,n);
cellCurrent = zeros(1,n);
packCurrent = zeros(1,n);
cellVoltage = zeros(1,n);
packVoltage = zeros(1,n);
cellOCV = zeros(1,n);
packOCV = zeros(1,n);
overVoltage = false(1,n);
underVoltage = false(1,n);
chargeInhibited = false(1,n);
chargeDerated = false(1,n);
dischargeInhibited = false(1,n);
socBoundaryLimited = false(1,n);
Vrc = 0;
soc(1) = InitialSOC;
temperature(1) = InitialCellTemperature;

for k = 1:n
    requestedCellCurrent = packCurrentCommand(k)/Pack.Np;
    appliedCellCurrent = requestedCellCurrent;

    % Inhibit charge/discharge requests outside the configured operating
    % window. This is a simulation rule, not a certified protection system.
    if appliedCellCurrent < 0 && ...
            (temperature(k) < Battery.MinChargeTemperature || ...
             temperature(k) > Battery.MaxChargeTemperature || ...
             soc(k) >= Battery.MaximumSOC)
        appliedCellCurrent = 0;
        chargeInhibited(k) = true;
    elseif appliedCellCurrent < 0 && ...
            temperature(k) < Battery.LowTempChargeTemperatureThreshold
        lowTempLimit = Battery.LowTempChargeCurrent;
        if abs(appliedCellCurrent) > lowTempLimit
            appliedCellCurrent = -lowTempLimit;
            chargeDerated(k) = true;
        end
    elseif appliedCellCurrent > 0 && ...
            (temperature(k) < Battery.MinCellTemperature || ...
             temperature(k) > Battery.MaxCellTemperature || ...
             soc(k) <= Battery.MinimumSOC)
        appliedCellCurrent = 0;
        dischargeInhibited(k) = true;
    end

    % Limit the next integration step at the configured SOC operating window.
    if k < n && appliedCellCurrent > 0
        availableDischargeA = max(0,(soc(k)-Battery.MinimumSOC)* ...
            Battery.DesignCapacity*3600/dt);
        if appliedCellCurrent > availableDischargeA
            appliedCellCurrent = availableDischargeA;
            socBoundaryLimited(k) = true;
        end
    elseif k < n && appliedCellCurrent < 0
        availableChargeA = max(0,(Battery.MaximumSOC-soc(k))* ...
            Battery.DesignCapacity*3600/dt);
        if abs(appliedCellCurrent) > availableChargeA
            appliedCellCurrent = -availableChargeA;
            socBoundaryLimited(k) = true;
        end
    end

    cellCurrent(k) = appliedCellCurrent;
    packCurrent(k) = appliedCellCurrent*Pack.Np;
    [cellVoltage(k),Vrc,cellOCV(k),status] = batteryECM( ...
        soc(k),appliedCellCurrent,Vrc,dt,Battery);
    packVoltage(k) = cellVoltage(k)*Pack.Ns;
    packOCV(k) = cellOCV(k)*Pack.Ns;
    overVoltage(k) = status.OverVoltage;
    underVoltage(k) = status.UnderVoltage;

    if k < n
        soc(k+1) = coulombCounting(soc(k),appliedCellCurrent, ...
            dt,Battery.DesignCapacity);
        heat = calcHeatGeneration(appliedCellCurrent,Battery);
        temperature(k+1) = updateTemperature(temperature(k), ...
            heat,AmbientTemperature,dt,Battery);
    end
end

Results.ProfileName = char(profile);
Results.PackConfiguration = Pack.Configuration;
Results.Time_s = time(:);
Results.RawPackCurrent_A = rawPackCurrent(:);
Results.CommandPackCurrent_A = packCurrentCommand(:);
Results.PackCurrent_A = packCurrent(:);
Results.CellCurrent_A = cellCurrent(:);
Results.CellTerminalVoltage_V = cellVoltage(:);
Results.PackTerminalVoltage_V = packVoltage(:);
Results.CellOCV_V = cellOCV(:);
Results.PackOCV_V = packOCV(:);
Results.SOC = soc(:);
Results.CellTemperature_C = temperature(:);
Results.OverVoltage = overVoltage(:);
Results.UnderVoltage = underVoltage(:);
Results.ChargeInhibited = chargeInhibited(:);
Results.ChargeCurrentDerated = chargeDerated(:);
Results.DischargeInhibited = dischargeInhibited(:);
Results.SOCBoundaryLimited = socBoundaryLimited(:);
Results.DischargeCurrentScale = dischargeScale;
Results.ChargeCurrentScale = chargeScale;
Results.VoltageLimitViolationCount = sum(overVoltage | underVoltage);
Results.ChargeInhibitionCount = sum(chargeInhibited);
Results.ChargeDeratingCount = sum(chargeDerated);
Results.DischargeInhibitionCount = sum(dischargeInhibited);
Results.SOCBoundaryLimitCount = sum(socBoundaryLimited);
Results.MaxCellDischargeCurrent_A = Battery.MaxDischargeCurrent;
Results.MaxCellStandardChargeCurrent_A = Battery.StandardChargeCurrent;
Results.LowTemperatureChargeCurrent_A = Battery.LowTempChargeCurrent;
Results.ModelNote = ['Synthetic current profiles are scaled to configured project ' ...
    'cell-current limits. Cell current equals pack current divided by Np.'];
end
