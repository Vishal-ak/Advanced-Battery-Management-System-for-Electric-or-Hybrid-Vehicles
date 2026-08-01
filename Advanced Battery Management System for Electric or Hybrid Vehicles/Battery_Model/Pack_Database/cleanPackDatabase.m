function PackDB = cleanPackDatabase(PackDB)
%===========================================================
% CLEAN BATTERY PACK DATABASE
%
% Converts imported Excel data into engineering parameters.
%
% Outputs:
%   - Numeric Voltage
%   - Numeric Capacity
%   - Numeric Current Ratings
%   - Numeric Weight
%   - Series / Parallel Configuration
%   - Total Cell Count
%   - Energy
%   - Specific Energy
%   - Dimensions
%   - Pack Volume
%   - Volumetric Energy Density
%===========================================================

%% Nominal Voltage (V)

PackDB.NominalVoltage_V = ...
    str2double(erase(string(PackDB.NominalVoltage_V),"V"));

%% Nominal Capacity (Ah)

capacity = string(PackDB.NominalCapacity_Ah);

isMilliAh = contains(capacity,"mAh");

capacity = erase(capacity,"Ah");
capacity = erase(capacity,"mAh");

capacity = str2double(capacity);

% Convert mAh to Ah

capacity(isMilliAh) = capacity(isMilliAh)/1000;

PackDB.NominalCapacity_Ah = capacity;

%% Charge Current (A)

PackDB.ChargeCurrent_A = ...
    str2double(erase(string(PackDB.ChargeCurrent_A),"A"));

%% Maximum Discharge Current (A)

PackDB.MaxDischargeCurrent_A = ...
    str2double(erase(string(PackDB.MaxDischargeCurrent_A),"A"));

%% Weight (kg)

weight = string(PackDB.Weight_kg);

isKg = contains(weight,"kg");

weight = erase(weight,"kg");
weight = erase(weight,"g");

weight = str2double(weight);

% Convert grams to kilograms

weight(~isKg) = weight(~isKg)/1000;

PackDB.Weight_kg = weight;

%% Extract Configuration (Ns & Np)

config = string(PackDB.Configuration);

Ns = NaN(height(PackDB),1);
Np = NaN(height(PackDB),1);

for k = 1:height(PackDB)

    token = regexp( ...
        config(k), ...
        '(\d+)S(\d+)P', ...
        'tokens', ...
        'once');

    if ~isempty(token)

        Ns(k) = str2double(token{1});
        Np(k) = str2double(token{2});

    end

end

PackDB.Ns = Ns;
PackDB.Np = Np;

%% Total Cell Count

PackDB.TotalCells = ...
    PackDB.Ns .* PackDB.Np;

%% Pack Energy

PackDB.Energy_Wh = ...
    PackDB.NominalVoltage_V .* ...
    PackDB.NominalCapacity_Ah;

PackDB.Energy_kWh = ...
    PackDB.Energy_Wh/1000;

%% Specific Energy

PackDB.SpecificEnergy_Whkg = ...
    PackDB.Energy_Wh ./ ...
    PackDB.Weight_kg;

%% Dimensions

dimension = string(PackDB.Dimensions_mm);

Length = NaN(height(PackDB),1);
Width  = NaN(height(PackDB),1);
Height = NaN(height(PackDB),1);

for k = 1:height(PackDB)

    token = regexp( ...
        dimension(k), ...
        '(\d+)\*(\d+)\*(\d+)', ...
        'tokens', ...
        'once');

    if ~isempty(token)

        Length(k) = str2double(token{1});
        Width(k)  = str2double(token{2});
        Height(k) = str2double(token{3});

    end

end

PackDB.Length_mm = Length;
PackDB.Width_mm  = Width;
PackDB.Height_mm = Height;

%% Pack Volume

PackDB.Volume_mm3 = ...
    Length .* Width .* Height;

PackDB.Volume_L = ...
    PackDB.Volume_mm3 / 1e6;

%% Volumetric Energy Density

PackDB.VolumetricEnergy_WhL = ...
    PackDB.Energy_Wh ./ PackDB.Volume_L;

%% Remove Invalid Entries

valid = ...
    ~isnan(PackDB.NominalVoltage_V) & ...
    ~isnan(PackDB.NominalCapacity_Ah) & ...
    ~isnan(PackDB.Ns) & ...
    ~isnan(PackDB.Np);

PackDB = PackDB(valid,:);

end