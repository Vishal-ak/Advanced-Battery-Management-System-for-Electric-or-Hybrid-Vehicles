function PackDB = loadPackDatabase()
%===========================================================
% LOAD BATTERY PACK DATABASE
%
% Loads the commercial battery pack database from Excel,
% cleans the imported data and computes derived parameters.
%
% Output
% ------
% PackDB : Clean battery pack database table
%===========================================================

%% Project Root

currentFile = mfilename('fullpath');

databaseFolder = fileparts(currentFile);

projectRoot = fileparts(databaseFolder);

%% Database File

filename = fullfile( ...
    projectRoot,...
    'Pack_Database',...
    'Packdata.xlsx');

%% Check File

if ~isfile(filename)
    error('Battery pack database not found:\n%s',filename);
end

%% Read Excel File

PackDB = readtable( ...
    filename,...
    'VariableNamingRule','modify');

%% Clean Database

PackDB = cleanPackDatabase(PackDB);

end