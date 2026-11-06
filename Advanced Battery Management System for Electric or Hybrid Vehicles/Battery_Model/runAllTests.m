function results = runAllTests()
% runAllTests  Run the automated MATLAB unit-test suite.
%
% Usage (from the canonical Battery_Model folder):
%   results = runAllTests();

projectRoot = fileparts(mfilename('fullpath'));
cd(projectRoot);

% Configure only the canonical source tree and automated test directory.
setupProject();

testFolder = fullfile(projectRoot, 'Tests', 'Automated_Test_File');
if ~isfolder(testFolder)
    error('BMS:MissingTestFolder', ...
        'Automated test folder not found: %s', testFolder);
end

results = runtests(testFolder);
disp(table(results));

if any([results.Failed]) || any([results.Incomplete])
    error('BMS:AutomatedTestsFailed', ...
        'One or more automated unit tests failed or did not complete.');
end

fprintf('All %d automated unit tests passed.\n', numel(results));
end
