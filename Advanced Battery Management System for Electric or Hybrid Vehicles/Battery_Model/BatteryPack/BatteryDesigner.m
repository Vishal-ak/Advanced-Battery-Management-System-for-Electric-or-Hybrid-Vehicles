function Report = BatteryDesigner(targetVoltage,targetCapacity)
%BATTERYDESIGNER Compare a commercial recommendation with a custom pack.
% Commercial recommendations are returned as a one-row-or-more MATLAB table;
% custom designs are scalar structures. This report normalizes their fields.

if nargin ~= 2 || ~isnumeric(targetVoltage) || ~isscalar(targetVoltage) || ...
        ~isfinite(targetVoltage) || targetVoltage <= 0 || ...
        ~isnumeric(targetCapacity) || ~isscalar(targetCapacity) || ...
        ~isfinite(targetCapacity) || targetCapacity <= 0
    error('BMS:InvalidDesignTarget', ...
        'Target voltage and capacity must be positive finite scalars.');
end

fprintf('\n=====================================================\n');
fprintf(' ADVANCED BATTERY DESIGN PLATFORM\n');
fprintf('=====================================================\n');
fprintf('Voltage requirement : %.2f V\n',targetVoltage);
fprintf('Capacity requirement: %.2f Ah\n',targetCapacity);

CommercialTable = recommendPack(targetVoltage,targetCapacity,1);
if isempty(CommercialTable)
    error('BMS:NoCommercialRecommendation', ...
        'The commercial battery database returned no recommendation.');
end
Commercial = table2struct(CommercialTable(1,:));

Custom = designPack(targetVoltage,targetCapacity);
Validation = validatePack(Custom);

commercialConfiguration = char(string(Commercial.Configuration));
fprintf('\n%-25s %-16s %-16s\n','Parameter','Commercial','Custom');
fprintf('%-25s %-16s %-16s\n','Configuration', ...
    commercialConfiguration,char(string(Custom.Configuration)));
fprintf('%-25s %-16.2f %-16.2f\n','Voltage (V)', ...
    Commercial.NominalVoltage_V,Custom.NominalVoltage);
fprintf('%-25s %-16.2f %-16.2f\n','Capacity (Ah)', ...
    Commercial.NominalCapacity_Ah,Custom.Capacity);
commercialEnergy = Commercial.NominalVoltage_V*Commercial.NominalCapacity_Ah;
fprintf('%-25s %-16.2f %-16.2f\n','Energy (Wh)', ...
    commercialEnergy,Custom.Energy_Wh);
fprintf('%-25s %-16.2f %-16.2f\n','Weight (kg)', ...
    Commercial.Weight_kg,Custom.Mass);
fprintf('%-25s %-16d %-16d\n','Total cells', ...
    round(Commercial.TotalCells),Custom.TotalCells);
fprintf('%-25s %-16.2f %-16.2f\n','Specific energy (Wh/kg)', ...
    Commercial.SpecificEnergy_Whkg,Custom.SpecificEnergy_Whkg);
fprintf('%-25s %-16.2f %-16.2f\n','Cell/pack density (Wh/L)', ...
    Commercial.VolumetricEnergy_WhL,Custom.EnergyDensity_WhL);

commercialScore = abs(Commercial.NominalVoltage_V-targetVoltage)/targetVoltage + ...
    abs(Commercial.NominalCapacity_Ah-targetCapacity)/targetCapacity;
customScore = abs(Custom.NominalVoltage-targetVoltage)/targetVoltage + ...
    abs(Custom.Capacity-targetCapacity)/targetCapacity;
if customScore < commercialScore
    recommendation = "CUSTOM";
    reason = "Lower voltage/capacity mismatch score.";
elseif commercialScore < customScore
    recommendation = "COMMERCIAL";
    reason = "Lower voltage/capacity mismatch score.";
else
    recommendation = "TIE";
    reason = "Equal voltage/capacity mismatch score.";
end

fprintf('\nRecommendation by voltage/capacity match: %s\n',recommendation);
fprintf('Reason: %s\n',reason);
fprintf('Custom-pack consistency validation: %s\n', ...
    string(Validation.IsValid));
fprintf('Validation errors: %d; warnings: %d\n', ...
    numel(Validation.Errors),numel(Validation.Warnings));

Report.Requirement.Voltage = targetVoltage;
Report.Requirement.Capacity = targetCapacity;
Report.Commercial = Commercial;
Report.Custom = Custom;
Report.Validation = Validation;
Report.Recommendation = recommendation;
Report.RecommendationReason = reason;
Report.Score.CommercialVoltageCapacity = commercialScore;
Report.Score.CustomVoltageCapacity = customScore;
end
