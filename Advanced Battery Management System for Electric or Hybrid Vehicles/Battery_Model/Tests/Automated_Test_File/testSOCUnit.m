
function tests = testSOCUnit
% Automated unit tests for Coulomb-counting SOC estimation.

tests = functiontests(localfunctions);
end

%% 1. SOC should decrease during discharge
function testSOCDecreasesDuringDischarge(testCase)

SOC_old = 0.80;
current = 5;       % Positive = discharge (A)
dt = 60;           % Time in seconds
capacity_Ah = 3.35;

expectedSOC = SOC_old - (current * dt) / (capacity_Ah * 3600);

actualSOC = coulombCounting(SOC_old, current, dt, capacity_Ah);

verifyEqual(testCase, actualSOC, expectedSOC, 'AbsTol', 1e-12);
verifyLessThan(testCase, actualSOC, SOC_old);

end

%% 2. SOC should increase during charging
function testSOCIncreasesDuringCharging(testCase)

SOC_old = 0.50;
current = -2;      % Negative = charging (A)
dt = 60;
capacity_Ah = 3.35;

expectedSOC = SOC_old - (current * dt) / (capacity_Ah * 3600);

actualSOC = coulombCounting(SOC_old, current, dt, capacity_Ah);

verifyEqual(testCase, actualSOC, expectedSOC, 'AbsTol', 1e-12);
verifyGreaterThan(testCase, actualSOC, SOC_old);

end

%% 3. SOC should remain unchanged at zero current
function testSOCUnchangedAtZeroCurrent(testCase)

SOC_old = 0.65;
current = 0;
dt = 60;
capacity_Ah = 3.35;

actualSOC = coulombCounting(SOC_old, current, dt, capacity_Ah);

verifyEqual(testCase, actualSOC, SOC_old, 'AbsTol', 1e-12);

end

%% 4. SOC should not exceed maximum limit
function testSOCUpperLimit(testCase)

SOC_old = 0.99;
current = -10;     % Charging
dt = 600;
capacity_Ah = 3.35;

actualSOC = coulombCounting(SOC_old, current, dt, capacity_Ah);

verifyEqual(testCase, actualSOC, 1);

end

%% 5. SOC should not fall below minimum limit (zero)
function testSOCLowerLimit(testCase)

SOC_old = 0.01;
current = 10;      % Discharging
dt = 600;
capacity_Ah = 3.35;

actualSOC = coulombCounting(SOC_old, current, dt, capacity_Ah);

verifyEqual(testCase, actualSOC, 0);

end

%% 6. Verify exact Coulomb-counting calculation
function testCoulombCountingCalculation(testCase)

SOC_old = 1.0;
current = 3.35;
dt = 3600;
capacity_Ah = 3.35;

expectedSOC = 0;

actualSOC = coulombCounting(SOC_old, current, dt, capacity_Ah);

verifyEqual(testCase, actualSOC, expectedSOC, 'AbsTol', 1e-12);

end
