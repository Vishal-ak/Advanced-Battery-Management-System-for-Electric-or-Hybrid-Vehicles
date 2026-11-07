function projectPaths = setupProject()
% Configure the canonical Battery_Model source tree and configuration APIs.
projectRoot=fileparts(mfilename('fullpath'));
requiredFolders={'BatteryPack';'Cell_Model/ECM';'Cell_Model/Thermal'; ...
 'Parameters';'SOC';'Simulation';'Simulation/CurrentProfile'; ...
 'Configuration';'Pack_Database'};
projectPaths=cell(size(requiredFolders));
for k=1:numel(requiredFolders)
 folder=fullfile(projectRoot,requiredFolders{k});
 if ~isfolder(folder), error('BMS:MissingFolder','Required folder is missing: %s',folder); end
 projectPaths{k}=folder;
end
addpath(projectPaths{:});
ocvFile=fullfile(projectRoot,'Cell_Library','Panasonic_NCR18650B','Data','OCV_SOC.csv');
if ~isfile(ocvFile), error('BMS:MissingOCVData','Required OCV file is missing: %s',ocvFile); end
testPath=fullfile(projectRoot,'Tests','Automated_Test_File');
if isfolder(testPath), addpath(testPath); end
fprintf('Battery Model paths configured.\nCanonical root: %s\n',projectRoot);
fprintf('Configuration API and simulation folders added.\n');
end
