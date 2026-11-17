%% Configure and display the canonical reference-cell pack
% All cell parameters are sourced from Parameters/initBattery.m.
Battery = initBattery();

Ns = 80;
Np = 1;
Pack = createBatteryPack(Battery,Ns,Np,false);

fprintf('\n========================================\n');
fprintf(' Panasonic NCR18650B Reference Pack\n');
fprintf('========================================\n');
fprintf('Cell capacity        : %.2f Ah\n',Battery.DesignCapacity);
fprintf('Pack capacity        : %.2f Ah\n',Pack.Capacity);
fprintf('Nominal voltage      : %.2f V\n',Pack.NominalVoltage);
fprintf('Maximum voltage      : %.2f V\n',Pack.MaximumVoltage);
fprintf('Cutoff voltage       : %.2f V\n',Pack.CutoffVoltage);
fprintf('Pack energy          : %.2f Wh\n',Pack.Energy_Wh);
fprintf('Series cells         : %d\n',Ns);
fprintf('Parallel cells       : %d\n',Np);
fprintf('ECM R0 / R1 / C1     : %.4f Ohm / %.4f Ohm / %.1f F\n', ...
    Battery.R0,Battery.R1,Battery.C1);
fprintf('========================================\n');
