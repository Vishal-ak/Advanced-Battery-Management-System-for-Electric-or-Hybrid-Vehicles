function tests = testAdvancedModules
% Regression tests for optional 2RC, passive balancing and regen modules.
tests = functiontests(localfunctions);
end

function testTwoRCReportsOverVoltageWithoutClipping(testCase)
Battery = initBattery();
[Vt,~,~,~,Status] = batteryECM_2RC(1,-100,0,0,1,Battery);
verifyGreaterThan(testCase,Vt,Battery.MaximumVoltage);
verifyTrue(testCase,Status.OverVoltage);
verifyFalse(testCase,Status.WithinVoltageLimits);
end

function testPassiveBalancingUsesOhmsLaw(testCase)
V = [3.80;3.82;3.805;3.825;3.80];
[active,current,spread] = passiveCellBalancing(V,39,0.015,true);
verifyEqual(testCase,spread,25,'AbsTol',1e-10);
verifyTrue(testCase,active(2));
verifyTrue(testCase,active(4));
verifyFalse(testCase,active(1));
verifyEqual(testCase,current(2),V(2)/39,'AbsTol',1e-12);
end

function testRegenCurrentRespectsVoltageHeadroom(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
Vpack = Pack.MaximumVoltage-0.01;
[Iregen,eta] = calcRegenerativeBraking(-5000,Vpack,0.70,25,Pack);
headroom = (Pack.MaximumVoltage-Vpack)/Pack.R0;
verifyLessThanOrEqual(testCase,abs(Iregen),headroom+1e-10);
verifyLessThan(testCase,Iregen,0);
verifyGreaterThan(testCase,eta,0);
end

function testRegenDisabledAtHighSOC(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
[Iregen,eta] = calcRegenerativeBraking(-5000,Pack.NominalVoltage,0.98,25,Pack);
verifyEqual(testCase,Iregen,0);
verifyEqual(testCase,eta,0);
end
end