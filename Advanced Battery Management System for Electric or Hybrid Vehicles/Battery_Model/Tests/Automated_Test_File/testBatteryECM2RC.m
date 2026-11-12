function tests = testBatteryECM2RC
%TESTBATTERYECM2RC Regression tests for the second-order Thevenin ECM.
tests = functiontests(localfunctions);
end

function testExactZeroOrderHoldUpdate(testCase)
v1 = 0.010; v2 = 0.005; current = 2.0; dt = 1.0;
R1 = 0.012; C1 = 2400; R2 = 0.015; C2 = 8000;
[a,b] = updateRCVoltage_2RC(v1,v2,current,dt,R1,C1,R2,C2);
expected1 = exp(-dt/(R1*C1))*v1 + R1*(1-exp(-dt/(R1*C1)))*current;
expected2 = exp(-dt/(R2*C2))*v2 + R2*(1-exp(-dt/(R2*C2)))*current;
verifyEqual(testCase,a,expected1,'AbsTol',1e-13);
verifyEqual(testCase,b,expected2,'AbsTol',1e-13);
end

function testZeroCurrentRelaxation(testCase)
v1 = 0.020; v2 = 0.010; dt = 3.0;
R1 = 0.012; C1 = 2400; R2 = 0.015; C2 = 8000;
[a,b] = updateRCVoltage_2RC(v1,v2,0,dt,R1,C1,R2,C2);
verifyEqual(testCase,a,v1*exp(-dt/(R1*C1)),'AbsTol',1e-13);
verifyEqual(testCase,b,v2*exp(-dt/(R2*C2)),'AbsTol',1e-13);
end

function testTerminalVoltageEquation(testCase)
v = terminalVoltage_2RC(3.8,2.0,0.045,0.01,0.005);
verifyEqual(testCase,v,3.8-2*0.045-0.01-0.005,'AbsTol',1e-12);
end

function testIntegrated2RCOutputAndInRangeStatus(testCase)
battery = initBattery();
[v,v1,v2,ocv,status] = batteryECM_2RC(0.8,2.0,0.01,0.005,1.0,battery);
expected = ocv - 2.0*battery.R0 - v1 - v2;
verifyEqual(testCase,v,expected,'AbsTol',1e-12);
verifyTrue(testCase,isfinite(v));
verifyTrue(testCase,status.WithinVoltageLimits);
verifyFalse(testCase,status.OverVoltage);
verifyFalse(testCase,status.UnderVoltage);
end

function testIntegrated2RCReportsUndervoltage(testCase)
battery = initBattery();
[~,~,~,~,status] = batteryECM_2RC(0.0,80.0,0,0,1.0,battery);
verifyTrue(testCase,status.UnderVoltage);
verifyFalse(testCase,status.WithinVoltageLimits);
end

function testIntegrated2RCReportsOvervoltage(testCase)
battery = initBattery();
[~,~,~,~,status] = batteryECM_2RC(1.0,-10.0,0,0,1.0,battery);
verifyTrue(testCase,status.OverVoltage);
verifyFalse(testCase,status.WithinVoltageLimits);
end

function testInvalidTimeStepRejected(testCase)
verifyError(testCase,@() updateRCVoltage_2RC(0,0,1,0,0.01,1000,0.02,2000),'BMS:Invalid2RCInput');
end

function testInvalidSOCRejected(testCase)
battery = initBattery();
verifyError(testCase,@() batteryECM_2RC(1.1,1,0,0,1,battery),'BMS:InvalidECMInput');
end
