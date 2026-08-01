function Results = recommendPack(targetVoltage, targetCapacity, topN)
%===========================================================
% RECOMMEND BATTERY PACKS
%
% Inputs
% -------
% targetVoltage   : Desired voltage (V)
% targetCapacity  : Desired capacity (Ah)
% topN            : Number of results (default = 5)
%
% Output
% -------
% Results         : Recommended battery packs
%===========================================================

%% Default

if nargin < 3
    topN = 5;
end

%% Load Database

PackDB = loadPackDatabase();

%% Volume (mm³)

dim = string(PackDB.Dimensions_mm);

Volume = zeros(height(PackDB),1);

for k = 1:height(PackDB)

    xyz = split(dim(k),"*");

    if numel(xyz)==3

        L = str2double(xyz(1));
        W = str2double(xyz(2));
        H = str2double(xyz(3));

        Volume(k)=L*W*H;

    else

        Volume(k)=NaN;

    end

end

PackDB.Volume_mm3 = Volume;

%% Calculate Errors

VoltageError = abs(PackDB.NominalVoltage_V - targetVoltage);

CapacityError = abs(PackDB.NominalCapacity_Ah - targetCapacity);

%% Normalize Errors

VoltageError = VoltageError ./ max(VoltageError);

CapacityError = CapacityError ./ max(CapacityError);



%% Weighted Score

WeightError = PackDB.Weight_kg ./ max(PackDB.Weight_kg);
VolumeError = PackDB.Volume_mm3 ./ max(PackDB.Volume_mm3);

VoltageWeight = 0.40;
CapacityWeight = 0.30;
WeightWeight = 0.15;
VolumeWeight = 0.15;

Score = ...
    VoltageWeight*VoltageError + ...
    CapacityWeight*CapacityError + ...
    WeightWeight*WeightError + ...
    VolumeWeight*VolumeError;

PackDB.Score = Score;

%% Sort

PackDB = sortrows(PackDB,"Score");

%% Return Best Results

topN = min(topN,height(PackDB));

Results = PackDB(1:topN,:);

end
