% VERIFYCOREPRIORITIES Execute available software checks for the frozen BMS scope.
% Run from the canonical Battery_Model directory:
%   report = verifyCorePriorities();
%
% IMPORTANT:
% Passing software checks do NOT establish physical model validation.
% Independent cell measurements and documented OCV/parameter provenance
% are required for physical validation.

function report = verifyCorePriorities()
projectRoot = fileparts(mfilename('fullpath'));
cd(projectRoot);
setupProject();
Battery = initBattery();

fprintf('\n============================================================\n');
fprintf(' BATTERY MANAGEMENT SYSTEM - CORE ENGINEERING CHECKS\n');
fprintf('============================================================\n');

report = struct();
report.ReferenceCellInitialized = isfield(Battery,'CellModel') && ...
    isfield(Battery,'TypicalCapacity') && isfield(Battery,'SOC_Table');
fprintf('[CHECK] Reference-cell structure initialized: %s\n', passFail(report.ReferenceCellInitialized));
fprintf('[LIMIT] Datasheet/OCV provenance independently verified: NOT ESTABLISHED\n');

% 1RC and 2RC executable calculations using the canonical Battery schema.
[V1,~,OCV1,Status1] = batteryECM(0.70,1.5,0,1,Battery);
report.OneRCExecutable = isfinite(V1) && isfinite(OCV1) && ...
    Status1.WithinVoltageLimits;
fprintf('[CHECK] 1RC calculation executable: %s (OCV %.4f V, Vt %.4f V)\n', ...
    passFail(report.OneRCExecutable),OCV1,V1);

[V2,~,~,OCV2,Status2] = batteryECM_2RC(0.70,1.5,0,0,1,Battery);
report.TwoRCExecutable = isfinite(V2) && isfinite(OCV2) && ...
    Status2.WithinVoltageLimits;
fprintf('[CHECK] 2RC calculation executable: %s (OCV %.4f V, Vt %.4f V)\n', ...
    passFail(report.TwoRCExecutable),OCV2,V2);

% Coulomb-counting arithmetic smoke check.
SOC0 = 0.80; Iload = 2.0; dt = 1.0;
SOCexpected = SOC0 - Iload*dt/(Battery.DesignCapacity*3600);
SOCactual = coulombCounting(SOC0,Iload,dt,Battery.DesignCapacity);
report.CoulombCountingArithmetic = abs(SOCactual-SOCexpected) <= 1e-12;
fprintf('[CHECK] Coulomb-counting one-step arithmetic: %s (SOC %.8f)\n', ...
    passFail(report.CoulombCountingArithmetic),SOCactual);
fprintf('[LIMIT] Long-duration SOC drift / bias validation: NOT ESTABLISHED\n');

% Execute the actual project thermal functions.
heat = calcHeatGeneration(Iload,Battery);
Tactual = updateTemperature(Battery.InitialTemperature,heat, ...
    Battery.InitialTemperature,dt,Battery);
Texpected = Battery.InitialTemperature + ...
    heat*dt/(Battery.Mass*Battery.SpecificHeat);
report.ThermalArithmetic = abs(Tactual-Texpected) <= 1e-12;
fprintf('[CHECK] Lumped thermal one-step calculation: %s (T %.6f degC)\n', ...
    passFail(report.ThermalArithmetic),Tactual);
fprintf('[LIMIT] Thermal model comparison with measured data: NOT ESTABLISHED\n');

% Execute complete automated MATLAB unit suite.
fprintf('\n[TEST] Running runAllTests()...\n');
report.AutomatedTestsPassed = false;
try
    testResults = runAllTests();
    report.AutomatedTestsPassed = ~isempty(testResults) && ...
        all([testResults.Passed]) && ~any([testResults.Failed]) && ...
        ~any([testResults.Incomplete]);
    report.TestCount = numel(testResults);
catch ME
    report.TestError = ME.message;
    fprintf(2,'[FAIL] Automated test suite: %s\n',ME.message);
end
fprintf('[TEST] Automated suite: %s\n',passFail(report.AutomatedTestsPassed));

report.SoftwareChecksPassed = report.ReferenceCellInitialized && ...
    report.OneRCExecutable && report.TwoRCExecutable && ...
    report.CoulombCountingArithmetic && report.ThermalArithmetic && ...
    report.AutomatedTestsPassed;

fprintf('\n============================================================\n');
if report.SoftwareChecksPassed
    fprintf(' SOFTWARE CHECKS PASSED.\n');
else
    fprintf(' SOFTWARE CHECKS INCOMPLETE OR FAILED.\n');
end
fprintf(' PHYSICAL VALIDATION IS NOT CLAIMED BY THIS SCRIPT.\n');
fprintf(' Independent voltage, SOC-drift and thermal datasets remain\n');
fprintf(' necessary before claiming model validation.\n');
fprintf('============================================================\n');
end

function label = passFail(condition)
if condition
    label = 'PASS';
else
    label = 'FAIL';
end
end
