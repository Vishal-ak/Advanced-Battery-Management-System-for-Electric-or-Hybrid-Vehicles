function Results = recommendPack(targetVoltage,targetCapacity,topN)
%RECOMMENDPACK Rank commercial packs against voltage/capacity requirements.
% Score is a heuristic comparison, not a safety or application-feasibility test.

if nargin < 2 || nargin > 3
    error('BMS:InvalidRecommendationInput', ...
        'Usage: recommendPack(targetVoltage,targetCapacity,[topN]).');
end
if nargin < 3 || isempty(topN), topN = 5; end
inputs = {targetVoltage,targetCapacity,topN};
validScalars = cellfun(@(v) isnumeric(v) && isreal(v) && ...
    isscalar(v) && isfinite(v),inputs);
if ~all(validScalars) || targetVoltage <= 0 || ...
        targetCapacity <= 0 || topN < 1 || fix(topN) ~= topN
    error('BMS:InvalidRecommendationInput', ...
        'Targets must be positive finite scalars and topN a positive integer.');
end

PackDB = loadPackDatabase();
required = {'NominalVoltage_V','NominalCapacity_Ah','Weight_kg', ...
    'Volume_mm3','Configuration','TotalCells','SpecificEnergy_Whkg', ...
    'VolumetricEnergy_WhL'};
if ~all(ismember(required,PackDB.Properties.VariableNames))
    error('BMS:InvalidPackDatabase', ...
        'Commercial pack database is missing one or more required columns.');
end
if height(PackDB) == 0
    error('BMS:EmptyPackDatabase','No commercial pack records are available.');
end

% Discard records that cannot be compared or ranked reliably.
valid = isfinite(PackDB.NominalVoltage_V) & PackDB.NominalVoltage_V > 0 & ...
    isfinite(PackDB.NominalCapacity_Ah) & PackDB.NominalCapacity_Ah > 0 & ...
    isfinite(PackDB.Weight_kg) & PackDB.Weight_kg > 0 & ...
    isfinite(PackDB.Volume_mm3) & PackDB.Volume_mm3 > 0 & ...
    isfinite(PackDB.TotalCells) & PackDB.TotalCells > 0;
PackDB = PackDB(valid,:);
if height(PackDB) == 0
    error('BMS:NoValidPackRecords', ...
        'No commercial pack rows contain valid voltage, capacity, mass, volume and cell-count values.');
end

voltageError = abs(PackDB.NominalVoltage_V-targetVoltage);
capacityError = abs(PackDB.NominalCapacity_Ah-targetCapacity);
voltageScore = normalizeNonnegative(voltageError);
capacityScore = normalizeNonnegative(capacityError);
weightScore = normalizeNonnegative(PackDB.Weight_kg);
volumeScore = normalizeNonnegative(PackDB.Volume_mm3);

PackDB.Score = 0.40*voltageScore + 0.30*capacityScore + ...
    0.15*weightScore + 0.15*volumeScore;
PackDB = sortrows(PackDB,{'Score','NominalVoltage_V','NominalCapacity_Ah'});
Results = PackDB(1:min(topN,height(PackDB)),:);
end

function scaled = normalizeNonnegative(values)
% Return zeros for a constant metric; avoid division by zero.
maximum = max(values);
if isempty(maximum) || ~isfinite(maximum) || maximum <= 0
    scaled = zeros(size(values));
else
    scaled = values./maximum;
end
end
