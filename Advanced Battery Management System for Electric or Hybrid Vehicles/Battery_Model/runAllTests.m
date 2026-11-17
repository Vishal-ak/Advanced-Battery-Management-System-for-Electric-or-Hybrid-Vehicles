function results = runAllTests()
%RUNALLTESTS Run the automated MATLAB tests from the canonical project tree.
% Usage: results = runAllTests();

projectRoot = fileparts(mfilename('fullpath'));
originalFolder = pwd;
restoreFolder = onCleanup(@() cd(originalFolder));
cd(projectRoot);

setupProject();

testFolder = fullfile(projectRoot,'Tests','Automated_Test_File');
if ~isfolder(testFolder)
    error('BMS:MissingTestFolder', ...
        'Automated test folder not found: %s',testFolder);
end

results = runtests(testFolder);
disp(results);

failedCount = sum([results.Failed]);
incompleteCount = sum([results.Incomplete]);
fprintf('\nAutomated test summary: %d total, %d failed, %d incomplete.\n', ...
    numel(results),failedCount,incompleteCount);

if failedCount > 0 || incompleteCount > 0
    error('BMS:AutomatedTestsFailed', ...
        'One or more automated unit tests failed or did not complete.');
end
fprintf('All %d automated tests passed.\n',numel(results));
end
