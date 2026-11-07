function Pack = designPack(targetVoltage,targetCapacity)
%DESIGNPACK Select a feasible series-parallel pack using a bounded heuristic.
% This routine is not a global optimizer and does not replace detailed
% electrical, thermal, mechanical, cost or safety design.

if nargin ~= 2 || ~isscalar(targetVoltage) || ~isscalar(targetCapacity) || ...
        ~isfinite(targetVoltage) || ~isfinite(targetCapacity) || ...
        targetVoltage <= 0 || targetCapacity <= 0
    error('BMS:InvalidDesignTarget', ...
        'Target voltage and capacity must be positive finite scalars.');
end

Battery = initBattery();
Ns_guess = round(targetVoltage/Battery.NominalVoltage);
Np_guess = round(targetCapacity/Battery.DesignCapacity);
Ns_min = max(1,Ns_guess-3); Ns_max = Ns_guess+3;
Np_min = max(1,Np_guess-3); Np_max = Np_guess+3;

hardwareMass = Battery.BMSWeight + Battery.EnclosureWeight + ...
    Battery.BusbarWeight + Battery.WiringWeight;
BestScore = inf; BestNs = []; BestNp = [];
for Ns = Ns_min:Ns_max
    Voltage = Ns*Battery.NominalVoltage;
    if Voltage < targetVoltage, continue; end
    for Np = Np_min:Np_max
        Capacity = Np*Battery.DesignCapacity;
        if Capacity < targetCapacity, continue; end
        totalMass = Ns*Np*Battery.Mass + hardwareMass;
        voltageError = abs(Voltage-targetVoltage)/targetVoltage;
        capacityError = abs(Capacity-targetCapacity)/targetCapacity;
        weightPenalty = totalMass/20; % normalized to a 20 kg reference
        score = 0.50*voltageError + 0.40*capacityError + 0.10*weightPenalty;
        if score < BestScore
            BestScore = score; BestNs = Ns; BestNp = Np;
        end
    end
end
if isempty(BestNs)
    error('BMS:NoFeasiblePack','No feasible battery pack found in search window.');
end

Pack = createBatteryPack(Battery,BestNs,BestNp,false);
Pack.CellModel = Battery.CellModel;
Pack.TargetVoltage = targetVoltage;
Pack.TargetCapacity = targetCapacity;
Pack.Score = BestScore;
Pack.VoltageError = Pack.NominalVoltage-targetVoltage;
Pack.CapacityError = Pack.Capacity-targetCapacity;
Pack.VoltageUtilization = targetVoltage/Pack.NominalVoltage;
Pack.CapacityUtilization = targetCapacity/Pack.Capacity;
Pack.CellCost = Pack.TotalCells*Battery.CellCost;
Pack.EstimatedCost = Pack.CellCost; % Excludes BMS, enclosure, assembly and test.
Pack.CostPerkWh = Pack.EstimatedCost/Pack.Energy_kWh;

fprintf('\n=====================================================\n');
fprintf(' OPTIMIZED BATTERY PACK DESIGN (HEURISTIC)\n');
fprintf('=====================================================\n');
fprintf('Cell Model           : %s\n',Pack.CellModel);
fprintf('Configuration        : %s\n',Pack.Configuration);
fprintf('Target               : %.2f V, %.2f Ah\n',targetVoltage,targetCapacity);
fprintf('Nominal               : %.2f V, %.2f Ah\n',Pack.NominalVoltage,Pack.Capacity);
fprintf('Energy                : %.2f Wh (%.3f kWh)\n',Pack.Energy_Wh,Pack.Energy_kWh);
fprintf('Cells / Mass          : %d / %.3f kg (hardware estimated)\n', ...
    Pack.TotalCells,Pack.Mass);
fprintf('Specific Energy       : %.2f Wh/kg\n',Pack.SpecificEnergy_Whkg);
fprintf('Cell-envelope density : %.2f Wh/L (not complete-pack density)\n', ...
    Pack.CellEnvelopeEnergyDensity_WhL);
fprintf('Cell-only cost        : INR %.0f\n',Pack.EstimatedCost);
fprintf('Cell-only cost/kWh    : INR %.2f/kWh\n',Pack.CostPerkWh);
fprintf('Optimization score   : %.5f (heuristic)\n',Pack.Score);
fprintf('=====================================================\n');
end