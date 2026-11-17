function tests = testPackCalculations
% Regression tests for reference-cell and series-parallel pack arithmetic.
tests = functiontests(localfunctions);
end

function testReferenceCellRatings(testCase)
Battery = initBattery();
verifyEqual(testCase,Battery.NominalVoltage,3.60,'AbsTol',1e-12);
verifyEqual(testCase,Battery.TypicalCapacity,3.35,'AbsTol',1e-12);
verifyEqual(testCase,Battery.MinimumCapacity,3.25,'AbsTol',1e-12);
verifyEqual(testCase,Battery.StandardChargeCurrent,1.625,'AbsTol',1e-12);
verifyEqual(testCase,Battery.MinChargeTemperature,0,'AbsTol',1e-12);
verifyEqual(testCase,Battery.MaxChargeTemperature,45,'AbsTol',1e-12);
end

function testThirteenSeriesSixParallelArithmetic(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
verifyEqual(testCase,Pack.TotalCells,78);
verifyEqual(testCase,Pack.NominalVoltage,46.8,'AbsTol',1e-10);
verifyEqual(testCase,Pack.MaximumVoltage,54.6,'AbsTol',1e-10);
verifyEqual(testCase,Pack.CutoffVoltage,32.5,'AbsTol',1e-10);
verifyEqual(testCase,Pack.Capacity,20.1,'AbsTol',1e-10);
verifyEqual(testCase,Pack.Energy_Wh,940.68,'AbsTol',1e-8);
verifyEqual(testCase,Pack.StandardChargeCurrent,9.75,'AbsTol',1e-10);
verifyEqual(testCase,Pack.MaxDischargeCurrent,30,'AbsTol',1e-10);
verifyEqual(testCase,Pack.MinChargeTemperature,0);
verifyEqual(testCase,Pack.MaxChargeTemperature,45);
end

function testDesignPackMeetsMinimumTargets(testCase)
Pack = designPack(48,20);
verifyGreaterThanOrEqual(testCase,Pack.NominalVoltage,48);
verifyGreaterThanOrEqual(testCase,Pack.Capacity,20);
verifyEqual(testCase,Pack.Ns,14);
verifyEqual(testCase,Pack.Np,6);
end

function testPackValidatorRejectsInvalidCellCount(testCase)
Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);
Pack.TotalCells = Pack.TotalCells+1;
Result = validatePack(Pack);
verifyFalse(testCase,Result.IsValid);
verifyNotEmpty(testCase,Result.Errors);
end
