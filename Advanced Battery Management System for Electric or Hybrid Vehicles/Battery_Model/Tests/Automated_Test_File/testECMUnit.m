function tests=testECMUnit
tests=functiontests(localfunctions);
end
function testRCZeroCurrent(testCase)
B=initBattery(); old=0.2; dt=1;
expected=exp(-dt/(B.R1*B.C1))*old;
actual=updateRCVoltage(old,0,dt,B.R1,B.C1);
verifyEqual(testCase,actual,expected,'AbsTol',1e-12);
end
function testRCStepResponse(testCase)
B=initBattery(); I=2; dt=1;
expected=B.R1*(1-exp(-dt/(B.R1*B.C1)))*I;
actual=updateRCVoltage(0,I,dt,B.R1,B.C1);
verifyEqual(testCase,actual,expected,'AbsTol',1e-12);
end
function testOCVLookup(testCase)
B=initBattery(); [Vt,Vrc,OCV]=batteryECM(0.5,0,0,1,B);
expected=interp1(B.SOC_Table,B.OCV_Table,0.5,'linear');
verifyEqual(testCase,OCV,expected,'AbsTol',1e-10);
verifyEqual(testCase,Vrc,0,'AbsTol',1e-12);
verifyEqual(testCase,Vt,OCV,'AbsTol',1e-12);
end
function testOverVoltageReported(testCase)
B=initBattery(); [Vt,~,~,S]=batteryECM(1,-100,0,1,B);
verifyGreaterThan(testCase,Vt,B.MaximumVoltage);
verifyTrue(testCase,S.OverVoltage);
verifyFalse(testCase,S.WithinVoltageLimits);
end
function testUnderVoltageReported(testCase)
B=initBattery(); [Vt,~,~,S]=batteryECM(0,100,0,1,B);
verifyLessThan(testCase,Vt,B.CutoffVoltage);
verifyTrue(testCase,S.UnderVoltage);
verifyFalse(testCase,S.WithinVoltageLimits);
end
function testInvalidTimeStep(testCase)
B=initBattery();
verifyError(testCase,@() batteryECM(0.5,1,0,0,B),'BMS:InvalidECMInput');
end