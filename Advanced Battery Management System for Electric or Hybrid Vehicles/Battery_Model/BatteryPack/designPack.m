function Pack = designPack(targetVoltage,targetCapacity)
%DESIGNPACK Bounded heuristic search for a feasible series/parallel pack.
% This routine is a heuristic, not a globally optimal engineering solver.

if nargin~=2 || ~isscalar(targetVoltage) || ~isscalar(targetCapacity) || ...
        ~isfinite(targetVoltage) || ~isfinite(targetCapacity) || ...
        targetVoltage<=0 || targetCapacity<=0
    error('BMS:InvalidDesignTarget','Targets must be positive finite scalars.');
end
Battery=initBattery();
Ns0=round(targetVoltage/Battery.NominalVoltage);
Np0=round(targetCapacity/Battery.DesignCapacity);
NsRange=max(1,Ns0-3):Ns0+3;
NpRange=max(1,Np0-3):Np0+3;
best=inf; bestNs=[]; bestNp=[];
hardware=0;
fields={'BMSWeight','EnclosureWeight','BusbarWeight','WiringWeight'};
for k=1:numel(fields)
    if isfield(Battery,fields{k}), hardware=hardware+Battery.(fields{k}); end
end
for Ns=NsRange
    V=Ns*Battery.NominalVoltage;
    if V<targetVoltage, continue; end
    for Np=NpRange
        C=Np*Battery.DesignCapacity;
        if C<targetCapacity, continue; end
        totalMass=Ns*Np*Battery.Mass+hardware;
        vErr=(V-targetVoltage)/targetVoltage;
        cErr=(C-targetCapacity)/targetCapacity;
        % Normalize mass to a 20 kg reference. Weights are design choices.
        score=0.50*vErr+0.40*cErr+0.10*(totalMass/20);
        if score<best, best=score; bestNs=Ns; bestNp=Np; end
    end
end
if isempty(bestNs), error('BMS:NoFeasiblePack','No feasible configuration found in search window.'); end
Pack=createBatteryPack(Battery,bestNs,bestNp,false);
Pack.CellModel=Battery.CellModel;
Pack.TargetVoltage=targetVoltage; Pack.TargetCapacity=targetCapacity;
Pack.Score=best;
Pack.VoltageError=Pack.NominalVoltage-targetVoltage;
Pack.CapacityError=Pack.Capacity-targetCapacity;
Pack.VoltageUtilization=targetVoltage/Pack.NominalVoltage;
Pack.CapacityUtilization=targetCapacity/Pack.Capacity;
Pack.CellCost=Pack.TotalCells*Battery.CellCost;
Pack.EstimatedCost=Pack.CellCost; % Cell-only estimate; excludes pack hardware/assembly.
Pack.CostPerkWh=Pack.EstimatedCost/Pack.Energy_kWh;

fprintf('\n=== OPTIMIZED PACK DESIGN (HEURISTIC) ===\n');
fprintf('Cell/configuration   : %s / %s\n',Pack.CellModel,Pack.Configuration);
fprintf('Nominal voltage      : %.2f V\n',Pack.NominalVoltage);
fprintf('Capacity / energy    : %.2f Ah / %.2f kWh\n',Pack.Capacity,Pack.Energy_kWh);
fprintf('Cells                : %d (%dS%dP)\n',Pack.TotalCells,Pack.Ns,Pack.Np);
fprintf('Cell mass            : %.3f kg\n',Pack.CellMass);
fprintf('Hardware mass est.   : %.3f kg\n',Pack.HardwareMass);
fprintf('Total mass estimate  : %.3f kg\n',Pack.Mass);
fprintf('Specific energy      : %.2f Wh/kg\n',Pack.SpecificEnergy_Whkg);
fprintf('Cell-envelope density: %.2f Wh/L (not complete-pack density)\n',Pack.EnergyDensity_WhL);
fprintf('Cell-only cost       : INR %.0f\n',Pack.EstimatedCost);
fprintf('Cell-only cost/kWh   : INR %.2f/kWh\n',Pack.CostPerkWh);
fprintf('Heuristic score      : %.5f\n',Pack.Score);
end