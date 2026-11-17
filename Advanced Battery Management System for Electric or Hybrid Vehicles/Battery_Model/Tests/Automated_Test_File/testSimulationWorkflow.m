function tests = testSimulationWorkflow
% Regression tests for pack-scaled dynamic simulation service.
tests = functiontests(localfunctions);
end

function testPackCurrentConvertedToPerCellCurrent(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
R = simulateBatteryPack(Battery,Pack,0.80,25,25,1,300, ...
    "Synthetic drive cycle");
verifyLessThanOrEqual(testCase,max(R.CellCurrent_A),Battery.MaxDischargeCurrent+1e-12);
verifyGreaterThanOrEqual(testCase,min(R.CellCurrent_A), ...
    -Battery.StandardChargeCurrent-1e-12);
verifyEqual(testCase,max(R.PackCurrent_A), ...
    max(R.CellCurrent_A)*Pack.Np,'AbsTol',1e-10);
verifyEqual(testCase,R.PackConfiguration,'13S6P');
end

function testLowTemperatureChargeUsesQuarterCRate(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
R = simulateBatteryPack(Battery,Pack,0.70,5,5,1,130, ...
    "Synthetic drive cycle");
verifyTrue(testCase,any(R.ChargeCurrentDerated));
verifyLessThanOrEqual(testCase,max(abs(R.CellCurrent_A(R.ChargeCurrentDerated))), ...
    Battery.LowTempChargeCurrent+1e-12);
end

function testChargingInhibitedBelowMinimumTemperature(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
R = simulateBatteryPack(Battery,Pack,0.70,-1,-1,1,130, ...
    "Synthetic drive cycle");
verifyTrue(testCase,any(R.ChargeInhibited));
verifyTrue(testCase,all(R.CellCurrent_A(R.ChargeInhibited)==0));
end

function testSimulationRejectsNonIntegralDuration(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
verifyError(testCase,@() simulateBatteryPack( ...
    Battery,Pack,0.80,25,25,1,10.5,"Constant discharge"), ...
    'BMS:InvalidSimulationTime');
end

function testConstantDischargeReducesSOC(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
R = simulateBatteryPack(Battery,Pack,0.80,25,25,1,60, ...
    "Constant discharge");
verifyLessThan(testCase,R.SOC(end),R.SOC(1));
end
