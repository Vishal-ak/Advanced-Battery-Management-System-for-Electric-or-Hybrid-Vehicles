function tests = test2RCUnit
%TEST2RCUNIT Analytical and input-validation tests for the 2RC Thevenin ECM.
tests = functiontests(localfunctions);
end

function testExactZeroCurrentDecay(testCase)
B = localParameters(); v1 = 0.10; v2 = 0.05; dt = 2.5;
[a,b] = updateRCVoltage_2RC(v1,v2,0,dt,B.R1,B.C1,B.R2,B.C2);
verifyEqual(testCase,a,exp(-dt/(B.R1*B.C1))*v1,'AbsTol',1e-13);
verifyEqual(testCase,b,exp(-dt/(B.R2*B.C2))*v2,'AbsTol',1e-13);
end

function testExactConstantCurrentResponse(testCase)
B = localParameters(); I = 2.0; dt = 1.0;
[a,b] = updateRCVoltage_2RC(0,0,I,dt,B.R1,B.C1,B.R2,B.C2);
e1 = B.R1*(1-exp(-dt/(B.R1*B.C1)))*I;
e2 = B.R2*(1-exp(-dt/(B.R2*B.C2)))*I;
verifyEqual(testCase,a,e1,'AbsTol',1e-13);
verifyEqual(testCase,b,e2,'AbsTol',1e-13);
end

function testTerminalVoltageEquation(testCase)
v = terminalVoltage_2RC(3.9,2.0,0.045,0.01,0.005);
verifyEqual(testCase,v,3.795,'AbsTol',1e-12);
end

function testIntegrated2RCOutputAndStatus(testCase)
B = localParameters();
[Vt,v1,v2,ocv,S] = batteryECM_2RC(0.8,2,0.01,0.005,1,B);
% At SOC=0.8, linear interpolation of [0,0.5,1] -> [3.0,3.7,4.2] gives 4.0 V.
verifyEqual(testCase,ocv,4.0,'AbsTol',1e-12);
verifyGreaterThan(testCase,Vt,2.0);
verifyLessThan(testCase,Vt,4.2);
verifyGreaterThan(testCase,v1,0.01);
verifyGreaterThan(testCase,v2,0.005);
verifyFalse(testCase,S.OverVoltage);
verifyFalse(testCase,S.UnderVoltage);
verifyTrue(testCase,S.WithinVoltageLimits);
end

function testInvalidTimeStepRejected(testCase)
B = localParameters();
verifyError(testCase,@() batteryECM_2RC(0.5,1,0,0,0,B),'BMS:InvalidECMInput');
end

function testInvalidSOCRejected(testCase)
B = localParameters();
verifyError(testCase,@() batteryECM_2RC(1.1,1,0,0,1,B),'BMS:InvalidSOC');
end

function testNonPositiveRCParameterRejected(testCase)
B = localParameters(); B.R2 = 0;
verifyError(testCase,@() batteryECM_2RC(0.5,1,0,0,1,B),'BMS:InvalidECMParameter');
end

function testMalformedOCVTableRejected(testCase)
B = localParameters(); B.SOC_Table = [0;0.5;0.5]; B.OCV_Table = [3.0;3.7;3.8];
verifyError(testCase,@() batteryECM_2RC(0.5,1,0,0,1,B),'BMS:InvalidOCVTable');
end

function testOverVoltageReported(testCase)
B = localParameters();
[~,~,~,~,S] = batteryECM_2RC(1,-100,0,0,1,B);
verifyTrue(testCase,S.OverVoltage);
verifyFalse(testCase,S.WithinVoltageLimits);
end

function testUnderVoltageReported(testCase)
B = localParameters();
[~,~,~,~,S] = batteryECM_2RC(0,100,0,0,1,B);
verifyTrue(testCase,S.UnderVoltage);
verifyFalse(testCase,S.WithinVoltageLimits);
end

function B = localParameters()
B.SOC_Table = [0;0.5;1.0];
B.OCV_Table = [3.0;3.7;4.2];
B.R0 = 0.045; B.R1 = 0.012; B.C1 = 2400;
B.R2 = 0.015; B.C2 = 8000;
B.MaximumVoltage = 4.2; B.CutoffVoltage = 2.5;
end
