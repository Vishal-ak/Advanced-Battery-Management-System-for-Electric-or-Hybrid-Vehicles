function Pack = designPack(targetVoltage,targetCapacity)
%===========================================================
% DESIGN CUSTOM BATTERY PACK
%
% Optimizes the series and parallel configuration for a
% desired battery pack voltage and capacity.
%
% Inputs
% -------
% targetVoltage   : Desired Pack Voltage (V)
% targetCapacity  : Desired Pack Capacity (Ah)
%
% Output
% -------
% Pack : Optimized Battery Pack Structure
%===========================================================

%% Input Validation

if nargin ~= 2
    error('Usage: designPack(targetVoltage,targetCapacity)');
end

if targetVoltage <= 0
    error('Target voltage must be positive.');
end

if targetCapacity <= 0
    error('Target capacity must be positive.');
end

%% Initialize Cell

Battery = initBattery();

Vcell = Battery.NominalVoltage;
Ccell = Battery.DesignCapacity;

%% Search Window

Ns_guess = round(targetVoltage/Vcell);
Np_guess = round(targetCapacity/Ccell);

Ns_min = max(1,Ns_guess-3);
Ns_max = Ns_guess+3;

Np_min = max(1,Np_guess-3);
Np_max = Np_guess+3;

%% Optimization

BestScore = inf;
BestNs = [];
BestNp = [];

for Ns = Ns_min:Ns_max

    Voltage = Ns * Vcell;

    if Voltage < targetVoltage
        continue;
    end

    for Np = Np_min:Np_max

        Capacity = Np * Ccell;

        if Capacity < targetCapacity
            continue;
        end

        CellWeight = Ns * Np * Battery.Mass;

        VoltageError = ...
            abs(Voltage-targetVoltage)/targetVoltage;

        CapacityError = ...
            abs(Capacity-targetCapacity)/targetCapacity;

        WeightPenalty = CellWeight/20;

        Score = ...
            0.50*VoltageError + ...
            0.40*CapacityError + ...
            0.10*WeightPenalty;

        if Score < BestScore

            BestScore = Score;

            BestNs = Ns;
            BestNp = Np;

        end

    end

end

%% Check Solution

if isempty(BestNs)

    error('No feasible battery pack found.');

end

%% Build Battery Pack

Pack = createBatteryPack( ...
    Battery,...
    BestNs,...
    BestNp);

fprintf('\n');
%% Additional Information

Pack.CellModel = Battery.CellModel;

Pack.TargetVoltage = targetVoltage;
Pack.TargetCapacity = targetCapacity;

Pack.Score = BestScore;

Pack.VoltageError = ...
    Pack.NominalVoltage-targetVoltage;

Pack.CapacityError = ...
    Pack.Capacity-targetCapacity;

Pack.Configuration = ...
    sprintf('%dS%dP',Pack.Ns,Pack.Np);

Pack.VoltageUtilization = ...
targetVoltage/Pack.NominalVoltage;

Pack.CapacityUtilization = ...
targetCapacity/Pack.Capacity;

%% Cost Estimation

Pack.CellCost = Pack.TotalCells * Battery.CellCost;

Pack.EstimatedCost =  Pack.CellCost;

Pack.CostPerkWh = Pack.EstimatedCost / Pack.Energy_kWh;
%% Display

fprintf('\n');
fprintf('=====================================================\n');
fprintf(' OPTIMIZED BATTERY PACK DESIGN\n');
fprintf('=====================================================\n');

fprintf('Cell Model           : %s\n',Pack.CellModel);
fprintf('Configuration        : %s\n',Pack.Configuration);

fprintf('\n');

fprintf('Target Voltage       : %.2f V\n',Pack.TargetVoltage);
fprintf('Target Capacity      : %.2f Ah\n',Pack.TargetCapacity);

fprintf('\n');

fprintf('Series Cells (Ns)    : %d\n',Pack.Ns);
fprintf('Parallel Cells (Np)  : %d\n',Pack.Np);
fprintf('Total Cells          : %d\n',Pack.TotalCells);

fprintf('\n');

fprintf('Nominal Voltage      : %.2f V\n',Pack.NominalVoltage);
fprintf('Maximum Voltage      : %.2f V\n',Pack.MaximumVoltage);
fprintf('Cutoff Voltage       : %.2f V\n',Pack.CutoffVoltage);

fprintf('\n');

fprintf('Capacity             : %.2f Ah\n',Pack.Capacity);
fprintf('Energy               : %.2f Wh\n',Pack.Energy_Wh);
fprintf('Energy               : %.2f kWh\n',Pack.Energy_kWh);

fprintf('\n');

fprintf('Maximum Current      : %.2f A\n',Pack.MaxDischargeCurrent);
fprintf('Charge Current       : %.2f A\n',Pack.StandardChargeCurrent);

fprintf('\n');

fprintf('Pack Mass            : %.2f kg\n',Pack.Mass);
fprintf('Specific Energy      : %.2f Wh/kg\n',Pack.SpecificEnergy_Whkg);
fprintf('Energy Density       : %.2f Wh/L\n',Pack.EnergyDensity_WhL);

fprintf('\n');

fprintf('Estimated Cost       : ₹ %.0f\n',Pack.EstimatedCost);
fprintf('Cost per kWh          : ₹ %.2f/Wh\n',Pack.CostPerkWh);

fprintf('\n');

fprintf('Voltage Error        : %.2f V\n',Pack.VoltageError);
fprintf('Capacity Error       : %.2f Ah\n',Pack.CapacityError);

fprintf('Voltage Utilization  : %.2f %%\n',100*Pack.VoltageUtilization);
fprintf('Capacity Utilization : %.2f %%\n',100*Pack.CapacityUtilization);

fprintf('Optimization Score   : %.5f\n',Pack.Score);

fprintf('\n');

fprintf('=====================================================\n');

end