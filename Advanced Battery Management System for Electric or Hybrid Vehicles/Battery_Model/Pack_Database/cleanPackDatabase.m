function PackDB = cleanPackDatabase(PackDB)
%CLEANPACKDATABASE Normalize commercial pack workbook fields into SI-style units.
% Numeric values in columns suffixed _V, _A and _kg are treated as already
% expressed in those units. Text entries may carry V, A, kg, g, Ah or mAh.

if ~istable(PackDB)
    error('BMS:InvalidPackDatabase','PackDB must be a MATLAB table.');
end
required = {'NominalVoltage_V','NominalCapacity_Ah','ChargeCurrent_A', ...
    'MaxDischargeCurrent_A','Weight_kg','Configuration','Dimensions_mm'};
if ~all(ismember(required,PackDB.Properties.VariableNames))
    error('BMS:InvalidPackDatabase', ...
        'Pack database table is missing one or more required columns.');
end

PackDB.NominalVoltage_V = parseUnitColumn(PackDB.NominalVoltage_V,'V',1);
PackDB.NominalCapacity_Ah = parseCapacityColumn(PackDB.NominalCapacity_Ah);
PackDB.ChargeCurrent_A = parseUnitColumn(PackDB.ChargeCurrent_A,'A',1);
PackDB.MaxDischargeCurrent_A = parseUnitColumn(PackDB.MaxDischargeCurrent_A,'A',1);
PackDB.Weight_kg = parseWeightColumn(PackDB.Weight_kg);

%% Series/parallel configuration
config = upper(strtrim(string(PackDB.Configuration)));
Ns = NaN(height(PackDB),1);
Np = NaN(height(PackDB),1);
for k = 1:height(PackDB)
    token = regexp(char(config(k)),'(\d+)\s*S\s*(\d+)\s*P','tokens','once');
    if ~isempty(token)
        Ns(k) = str2double(token{1});
        Np(k) = str2double(token{2});
    end
end
PackDB.Ns = Ns;
PackDB.Np = Np;
PackDB.TotalCells = Ns.*Np;

%% Derived electrical values
PackDB.Energy_Wh = PackDB.NominalVoltage_V.*PackDB.NominalCapacity_Ah;
PackDB.Energy_kWh = PackDB.Energy_Wh/1000;
PackDB.SpecificEnergy_Whkg = PackDB.Energy_Wh./PackDB.Weight_kg;

%% Parse dimensions in mm; accepts *, x, X or × separators and decimals
dimension = strtrim(string(PackDB.Dimensions_mm));
Length = NaN(height(PackDB),1);
Width = NaN(height(PackDB),1);
Height = NaN(height(PackDB),1);
for k = 1:height(PackDB)
    token = regexp(char(dimension(k)), ...
        '([-+]?\d*\.?\d+)\s*[*xX×]\s*([-+]?\d*\.?\d+)\s*[*xX×]\s*([-+]?\d*\.?\d+)', ...
        'tokens','once');
    if ~isempty(token)
        Length(k) = str2double(token{1});
        Width(k) = str2double(token{2});
        Height(k) = str2double(token{3});
    end
end
PackDB.Length_mm = Length;
PackDB.Width_mm = Width;
PackDB.Height_mm = Height;
PackDB.Volume_mm3 = Length.*Width.*Height;
PackDB.Volume_L = PackDB.Volume_mm3/1e6;
PackDB.VolumetricEnergy_WhL = PackDB.Energy_Wh./PackDB.Volume_L;

%% Keep only records that can be ranked without invalid arithmetic
valid = isfinite(PackDB.NominalVoltage_V) & PackDB.NominalVoltage_V > 0 & ...
    isfinite(PackDB.NominalCapacity_Ah) & PackDB.NominalCapacity_Ah > 0 & ...
    isfinite(PackDB.Weight_kg) & PackDB.Weight_kg > 0 & ...
    isfinite(PackDB.Ns) & PackDB.Ns >= 1 & ...
    isfinite(PackDB.Np) & PackDB.Np >= 1 & ...
    isfinite(PackDB.Volume_mm3) & PackDB.Volume_mm3 > 0;
PackDB = PackDB(valid,:);
end

function values = parseUnitColumn(raw,unit,scale)
if isnumeric(raw)
    values = double(raw);
else
    txt = lower(strtrim(string(raw)));
    txt = replace(txt,",","");
    txt = regexprep(txt,['\s*' lower(unit) '\s*$'],'');
    values = str2double(txt);
end
values = values(:)*scale;
end

function values = parseCapacityColumn(raw)
if isnumeric(raw)
    values = double(raw(:)); % Column contract is Ah for numeric cells.
    return;
end
txt = lower(strtrim(string(raw)));
values = NaN(size(txt));
for k = 1:numel(txt)
    token = replace(txt(k),",","");
    factor = 1;
    if contains(token,"mah")
        token = erase(token,"mah"); % Remove mAh before testing Ah.
        factor = 1e-3;
    elseif contains(token,"ah")
        token = erase(token,"ah");
    end
    values(k) = str2double(strtrim(token))*factor;
end
values = values(:);
end

function values = parseWeightColumn(raw)
if isnumeric(raw)
    values = double(raw(:)); % Column contract is kg for numeric cells.
    return;
end
txt = lower(strtrim(string(raw)));
values = NaN(size(txt));
for k = 1:numel(txt)
    token = replace(txt(k),",","");
    if contains(token,"kg")
        token = erase(token,"kg");
        factor = 1;
    elseif contains(token,"g")
        token = erase(token,"g");
        factor = 1e-3;
    else
        factor = 1; % Weight_kg column default is kg when no suffix is supplied.
    end
    values(k) = str2double(strtrim(token))*factor;
end
values = values(:);
end
