
function projectPaths = setupProject()
% setupProject  Configure the canonical Battery_Model source tree.
% Run from the canonical Battery_Model folder:
%   projectPaths = setupProject();
%
% The nested Battery_Model/Battery_Model directory is a legacy duplicate
% and is deliberately excluded to prevent MATLAB path shadowing.

projectRoot = fileparts(mfilename('fullpath'));

requiredFolders = {
    'BatteryPack'
    'Cell_Model/ECM'
    'Cell_Model/Thermal'
    'Parameters'
    'SOC'
    'Simulation'
    'Simulation/CurrentProfile'
    'Pack_Database'
    };

projectPaths = cell(size(requiredFolders));

for k = 1:numel(requiredFolders)
    folder = fullfile(projectRoot, requiredFolders{k});

    if ~isfolder(folder)
        error('BMS:MissingFolder', ...
            'Required folder is missing: %s', folder);
    end

    projectPaths{k} = folder;
end

% Add required project folders
addpath(projectRoot, projectPaths{:});

% Verify OCV data
ocvFile = fullfile(projectRoot, 'Cell_Library', ...
    'Panasonic_NCR18650B', 'Data', 'OCV_SOC.csv');

if ~isfile(ocvFile)
    error('BMS:MissingOCVData', ...
        'Required OCV file is missing: %s', ocvFile);
end

% Add automated unit test directory
testPath = fullfile(projectRoot, ...
    'Tests', 'Automated_Test_File');

if isfolder(testPath)
    addpath(testPath);
    fprintf('Automated test directory added: %s\n', testPath);
else
    warning('BMS:MissingTestFolder', ...
        'Automated test directory not found: %s', testPath);
end

fprintf('Battery Model paths configured.\n');
fprintf('Canonical root: %s\n', projectRoot);
fprintf('OCV data: %s\n', ocvFile);
fprintf('Nested legacy duplicate was not added to the MATLAB path.\n');

end
