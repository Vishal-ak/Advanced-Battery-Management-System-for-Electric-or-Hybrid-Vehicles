
function tests = testThermalModel
% Automated unit tests for the battery thermal model.

tests = functiontests(localfunctions);

end

function testHeatGeneration(testCase)

Battery = initBattery();

Current = 5;
ExpectedHeat = Current^2 * Battery.R0;

ActualHeat = calcHeatGeneration(Current, Battery);

verifyEqual(testCase, ActualHeat, ExpectedHeat, ...
    'AbsTol', 1e-12);

end

function testNoTemperatureChangeAtAmbient(testCase)

Battery = initBattery();

T_ambient = 25;
Heat = 0;
dt = 1;

ActualTemperature = updateTemperature( ...
    T_ambient, Heat, T_ambient, dt, Battery);

verifyEqual(testCase, ActualTemperature, T_ambient, ...
    'AbsTol', 1e-12);

end

function testTemperatureRise(testCase)

Battery = initBattery();

InitialTemperature = 25;
AmbientTemperature = 25;
Current = 5;
dt = 1;

Heat = calcHeatGeneration(Current, Battery);

NewTemperature = updateTemperature( ...
    InitialTemperature, Heat, AmbientTemperature, dt, Battery);

verifyGreaterThan(testCase, NewTemperature, InitialTemperature);

end

function testCooling(testCase)

Battery = initBattery();

InitialTemperature = 40;
AmbientTemperature = 25;
Heat = 0;
dt = 1;

NewTemperature = updateTemperature( ...
    InitialTemperature, Heat, AmbientTemperature, dt, Battery);

verifyLessThan(testCase, NewTemperature, InitialTemperature);

end
