
function tests = testECMUnit
% Automated unit tests for the first-order battery ECM.

tests = functiontests(localfunctions);
end

function testRCVoltageAtZeroCurrent(testCase)

Battery = initBattery();

Vrc_old = 0.2;
dt = 1;
Current = 0;

Expected = exp(-dt/(Battery.R1*Battery.C1))*Vrc_old;

Actual = updateRCVoltage( ...
    Vrc_old, Current, dt, Battery.R1, Battery.C1);

verifyEqual(testCase, Actual, Expected, 'AbsTol', 1e-12);

end

function testRCVoltageAtZeroInitialPolarization(testCase)

Battery = initBattery();

Current = 2;
dt = 1;

Expected = Battery.R1 * ...
    (1-exp(-dt/(Battery.R1*Battery.C1))) * Current;

Actual = updateRCVoltage( ...
    0, Current, dt, Battery.R1, Battery.C1);

verifyEqual(testCase, Actual, Expected, 'AbsTol', 1e-12);

end

function testRCVoltageSteadyState(testCase)

Battery = initBattery();

Current = 2;
Vrc_old = Battery.R1*Current;
dt = 1;

Actual = updateRCVoltage( ...
    Vrc_old, Current, dt, Battery.R1, Battery.C1);

verifyEqual(testCase, Actual, Vrc_old, 'AbsTol', 1e-12);

end

function testOCVLookup(testCase)

Battery = initBattery();

SOC = 0.5;
Current = 0;
Vrc_old = 0;
dt = 1;

[Vt, Vrc, OCV] = batteryECM( ...
    SOC, Current, Vrc_old, dt, Battery);

ExpectedOCV = interp1( ...
    Battery.SOC_Table, Battery.OCV_Table, SOC, 'linear');

verifyEqual(testCase, OCV, ExpectedOCV, 'AbsTol', 1e-10);
verifyEqual(testCase, Vrc, 0, 'AbsTol', 1e-12);

end

function testTerminalVoltageLimits(testCase)

Battery = initBattery();

% High SOC, high charging current: upper voltage clamp
[V_high, ~, ~] = batteryECM( ...
    1, -100, 0, 1, Battery);

verifyEqual(testCase, V_high, Battery.MaximumVoltage, ...
    'AbsTol', 1e-12);

% Low SOC, high discharge current: lower voltage clamp
[V_low, ~, ~] = batteryECM( ...
    0, 100, 0, 1, Battery);

verifyEqual(testCase, V_low, Battery.CutoffVoltage, ...
    'AbsTol', 1e-12);

end
