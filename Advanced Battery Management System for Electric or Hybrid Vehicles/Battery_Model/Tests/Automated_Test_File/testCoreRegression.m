function tests = testCoreRegression
%TESTCOREREGRESSION Regression tests for reference cell, 1RC, SOC and thermal.
tests = functiontests(localfunctions);
end

function testReferenceCellKeyValues(testCase)
battery = initBattery();
verifyEqual(testCase,battery.NominalVoltage,3.6,'AbsTol',1e-12);
verifyEqual(testCase,battery.MinimumCapacity,3.25,'AbsTol',1e-12);
verifyEqual(testCase,battery.TypicalCapacity,3.35,'AbsTol',1e-12);
verifyEqual(testCase,battery.MaximumVoltage,4.2,'AbsTol',1e-12);
verifyEqual(testCase,battery.CutoffVoltage,2.5,'AbsTol',1e-12);
verifyEqual(testCase,battery.StandardChargeCurrent,1.625,'AbsTol',1e-12);
verifyEqual(testCase,battery.MaxDischargeCurrent,4.875,'AbsTol',1e-12);
verifyTrue(testCase,all(diff(battery.SOC_Table)>0));
verifyTrue(testCase,all(diff(battery.OCV_Table)>=0));
end

function test1RCVoltageEquationAndStatus(testCase)
battery = initBattery();
soc = 0.8; current = 2.0; vrc0 = 0.01; dt = 1.0;
[v,vrc,ocv,status] = batteryECM(soc,current,vrc0,dt,battery);
expectedVrc = exp(-dt/(battery.R1*battery.C1))*vrc0 + battery.R1*(1-exp(-dt/(battery.R1*battery.C1)))*current;
verifyEqual(testCase,vrc,expectedVrc,'AbsTol',1e-12);
verifyEqual(testCase,v,ocv-current*battery.R0-vrc,'AbsTol',1e-12);
verifyTrue(testCase,status.WithinVoltageLimits);
end

function testCoulombCountingDischarge(testCase)
capacity = 3.35; soc0 = 0.8; current = 2.0; dt = 1.0;
actual = coulombCounting(soc0,current,dt,capacity);
expected = soc0-current*dt/(capacity*3600);
verifyEqual(testCase,actual,expected,'AbsTol',1e-12);
end

function testCoulombCountingBounds(testCase)
verifyEqual(testCase,coulombCounting(0.001,10,10,1),0,'AbsTol',1e-12);
verifyEqual(testCase,coulombCounting(0.999,-10,10,1),1,'AbsTol',1e-12);
end

function testThermalModelAgainstEulerEquation(testCase)
battery = initBattery();
t0 = 25; tamb = 25; heat = 1.0; dt = 10;
expected = t0 + (heat-(t0-tamb)/battery.ThermalResistance)*dt / (battery.Mass*battery.SpecificHeat);
actual = updateTemperature(t0,heat,tamb,dt,battery);
verifyEqual(testCase,actual,expected,'AbsTol',1e-12);
end

function testThermalCooling(testCase)
battery = initBattery();
actual = updateTemperature(40,0,25,1,battery);
verifyLessThan(testCase,actual,40);
verifyGreaterThan(testCase,actual,25);
end
