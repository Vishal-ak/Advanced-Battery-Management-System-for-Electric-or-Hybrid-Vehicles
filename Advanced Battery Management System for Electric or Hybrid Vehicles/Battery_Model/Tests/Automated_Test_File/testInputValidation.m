function tests = testInputValidation
% Regression tests for malformed inputs to reusable model functions.
tests = functiontests(localfunctions);
end

function testCoulombCountingRejectsInvalidCapacity(testCase)
verifyError(testCase,@() coulombCounting(0.5,1,1,0), ...
    'BMS:InvalidCapacity');
end

function testCoulombCountingRejectsInvalidSOC(testCase)
verifyError(testCase,@() coulombCounting(1.2,1,1,3.35), ...
    'BMS:InvalidSOC');
end

function testCoulombCountingRejectsNonFiniteCurrent(testCase)
verifyError(testCase,@() coulombCounting(0.5,NaN,1,3.35), ...
    'BMS:InvalidSOCInput');
end

function testRCUpdateRejectsNonPositiveResistance(testCase)
verifyError(testCase,@() updateRCVoltage(0,1,1,0,100), ...
    'BMS:InvalidRCParameter');
end

function testTwoRCZeroCurrentReturnsOCV(testCase)
Battery = initBattery();
[Vt,Vrc1,Vrc2,OCV] = batteryECM_2RC(0.5,0,0,0,1,Battery);
verifyEqual(testCase,Vt,OCV,'AbsTol',1e-12);
verifyEqual(testCase,Vrc1,0,'AbsTol',1e-12);
verifyEqual(testCase,Vrc2,0,'AbsTol',1e-12);
end

function testECMRejectsUnsortedOCVTable(testCase)
Battery = initBattery();
Battery.SOC_Table([1 2]) = Battery.SOC_Table([2 1]);
verifyError(testCase,@() batteryECM(0.5,0,0,1,Battery), ...
    'BMS:InvalidOCVTable');
end

function testHeatGenerationRejectsNonFiniteCurrent(testCase)
Battery = initBattery();
verifyError(testCase,@() calcHeatGeneration(NaN,Battery), ...
    'BMS:InvalidThermalInput');
end

function testTemperatureUpdateRejectsZeroTimeStep(testCase)
Battery = initBattery();
verifyError(testCase,@() updateTemperature(25,1,25,0,Battery), ...
    'BMS:InvalidThermalInput');
end

function testTerminalVoltageRejectsInvalidResistance(testCase)
verifyError(testCase,@() terminalVoltage(3.7,1,0,0), ...
    'BMS:InvalidECMParameter');
end

function testPackVoltageRejectsInvalidSeriesCount(testCase)
Pack.Ns = 0;
verifyError(testCase,@() packVoltage(3.7,Pack), ...
    'BMS:InvalidPackConfiguration');
end

function testPackCurrentRejectsInvalidParallelCount(testCase)
Pack.Np = 1.5;
verifyError(testCase,@() packCurrent(1,Pack), ...
    'BMS:InvalidPackConfiguration');
end

function testPackPowerRejectsNonFiniteInputs(testCase)
verifyError(testCase,@() packPower(48,Inf), ...
    'BMS:InvalidPackPowerInput');
end

function testPackEnergyRejectsZeroCapacity(testCase)
verifyError(testCase,@() packEnergy(48,0), ...
    'BMS:InvalidPackEnergyInput');
end
