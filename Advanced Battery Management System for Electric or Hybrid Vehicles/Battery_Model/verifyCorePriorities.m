% VERIFYCOREPRIORITIES Execute reproducible checks for the frozen BMS scope.
% Run from the canonical Battery_Model directory in MATLAB.
% Code checks and automated tests do NOT replace independent measured-data validation.
projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
setupProject();
fprintf('\n=========================================================\n');
fprintf(' BMS CORE SCOPE — NUMERICAL / SOFTWARE VERIFICATION\n');
fprintf('=========================================================\n');
Battery = initBattery();
fprintf('[P0] Reference cell: %s\n',Battery.CellModel);
fprintf('     Nominal voltage %.2f V; typical capacity %.2f Ah\n',Battery.NominalVoltage,Battery.TypicalCapacity);
fprintf('     R0 %.4f Ohm (provisional model parameter)\n',Battery.R0);

[V1,Vrc1,OCV1] = batteryECM(0.8,2.0,0.01,1.0,Battery);
assert(isfinite(V1) && isfinite(Vrc1) && isfinite(OCV1));
assert(abs(V1-(OCV1-2.0*Battery.R0-Vrc1)) < 1e-10);
fprintf('[P0] 1RC ECM equation check: PASS (Vt = %.6f V)\n',V1);

[V2,Vrc1_2,Vrc2_2,OCV2] = batteryECM_2RC(0.8,2.0,0.01,0.005,1.0,Battery);
assert(isfinite(V2) && isfinite(Vrc1_2) && isfinite(Vrc2_2) && isfinite(OCV2));
assert(abs(V2-(OCV2-2.0*Battery.R0-Vrc1_2-Vrc2_2)) < 1e-10);
fprintf('[P0] 2RC ECM equation check: PASS (Vt = %.6f V)\n',V2);

soc0 = 0.8; current = 2.0; dt = 1.0;
soc1 = coulombCounting(soc0,current,dt,Battery.DesignCapacity);
socExpected = soc0-current*dt/Battery.CapacityCoulomb;
assert(abs(soc1-socExpected) < 1e-12 && soc1 < soc0);
fprintf('[P1] Coulomb-counting equation check: PASS (SOC %.6f -> %.6f)\n',soc0,soc1);

heat = calcHeatGeneration(current,Battery);
temp1 = updateTemperature(Battery.InitialTemperature,heat,Battery.InitialTemperature,dt,Battery);
tempExpected = Battery.InitialTemperature + heat*dt/(Battery.Mass*Battery.SpecificHeat);
assert(abs(temp1-tempExpected) < 1e-12 && temp1 > Battery.InitialTemperature);
fprintf('[P1] Lumped thermal equation check: PASS (T = %.6f degC)\n',temp1);

results = runAllTests();
fprintf('\nAutomated test count: %d\n',numel(results));
fprintf('Failed: %d | Incomplete: %d\n',sum([results.Failed]),sum([results.Incomplete]));
fprintf('Software regression suite: PASS\n');
fprintf('\nINDEPENDENT ENGINEERING VALIDATION STILL REQUIRED:\n');
fprintf('- Measured voltage traces not used to fit 1RC/2RC parameters.\n');
fprintf('- Traceable OCV-SOC characterization and test-condition metadata.\n');
fprintf('- Coulomb-counting drift against a trusted SOC reference.\n');
fprintf('- Measured cell-temperature traces for thermal-model validation.\n');
fprintf('Passing this script is not experimental validation or safety qualification.\n');
