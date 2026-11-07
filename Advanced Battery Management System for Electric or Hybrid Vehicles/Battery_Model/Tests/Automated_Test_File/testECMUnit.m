function tests = testECMUnit
% Automated unit tests for the first-order battery ECM.
tests = functiontests(localfunctions);
end

function testRCVoltageAtZeroCurrent(testCase)
Battery = initBattery();
Vrc_old = 0.2; dt = 1; Current = 0;
Expected = exp(-dt/(Battery.R1*Battery.C1))*Vrc_old;
Actual = updateRCVoltage(Vrc_old,Current,dt,Battery.R1,Battery.C1);
verifyEqual(testCase,Actual,Expected,'AbsTol',1e-12);
end

function testRCVoltageAtZeroInitialPolarization(testCase)
Battery = initBattery();
Current = 2; dt = 1;
Expected = Battery.R1*(1-exp(-dt/(Battery.R1*Battery.C1)))*Current;
Actual = updateRCVoltage(0,Current,dt,Battery.R1,Battery.C1);
verifyEqual(testCase,Actual,Expected,'AbsTol',1e-12);
end

function testRCVoltageSteadyState(testCase)
Battery = initBattery();
Current = 2; Vrc_old = Battery.R1*Current; dt = 1;
Actual = updateRCVoltage(Vrc_old,Current,dt,Battery.R1,Battery.C1);
verifyEqual(testCase,Actual,Vrc_old,'AbsTol',1e-12);
end

function testOCVLookup(testCase)
Battery = initBattery();
[Vt,Vrc,OCV] = batteryECM(0.5,0,0,1,Battery);
ExpectedOCV = interp1(Battery.SOC_Table,Battery.OCV_Table,0.5,'linear');
verifyEqual(testCase,OCV,ExpectedOCV,'AbsTol',1e-10);
verifyEqual(testCase,Vrc,0,'AbsTol',1e-12);
verifyEqual(testCase,Vt,OCV,'AbsTol',1e-12);
end

function testOverVoltageReportedWithoutClipping(testCase)
Battery = initBattery();
[Vt,~,~,Status] = batteryECM(1,-100,0,1,Battery);
verifyGreaterThan(testCase,Vt,Battery.MaximumVoltage);
verifyTrue(testCase,Status.OverVoltage);
verifyFalse(testCase,Status.WithinVoltageLimits);
end

function testUnderVoltageReportedWithoutClipping(testCase)
Battery = initBattery();
[Vt,~,~,Status] = batteryECM(0,100,0,1,Battery);
verifyLessThan(testCase,Vt,Battery.CutoffVoltage);
verifyTrue(testCase,Status.UnderVoltage);
verifyFalse(testCase,Status.WithinVoltageLimits);
end

function testInvalidTimeStepRejected(testCase)
Battery = initBattery();
verifyError(testCase,@() batteryECM(0.5,1,0,0,Battery), ...
    'BMS:InvalidECMInput');
end