%% Dynamic 1RC ECM simulation for a 13S6P reference pack
% driveCycleCurrent returns PACK current (A). The cell ECM is a single-cell
% model, so divide pack current by Np before applying it to the cell model.
% The selected 13S6P configuration gives 30 A pack discharge = 5 A/cell.

clear;
clc;
close all;

Battery = initBattery();
Pack = createBatteryPack(Battery,13,6,false);

dt = 1;
T_end = 300;
t = 0:dt:T_end;

PackCurrent = driveCycleCurrent(t);
CellCurrent = PackCurrent/Pack.Np;

if any(PackCurrent > Pack.MaxDischargeCurrent)
    error('BMS:DriveCycleExceedsDischargeLimit', ...
        'Pack current profile exceeds the configured pack discharge-current limit.');
end
if any(PackCurrent < -Pack.StandardChargeCurrent)
    warning('BMS:DriveCycleExceedsStandardCharge', ...
        'Regenerative current exceeds the configured standard charge-current level; verify cell charge limits.');
end

InitialSOC = 0.80; % Leave headroom for the regenerative-braking interval.
SOC = zeros(size(t));
SOC(1) = InitialSOC;
CellVoltage = zeros(size(t));
PackVoltage = zeros(size(t));
OCV = zeros(size(t));
OverVoltage = false(size(t));
UnderVoltage = false(size(t));

Vrc = 0;
for k = 1:numel(t)
    if k > 1
        SOC(k) = coulombCounting(SOC(k-1),CellCurrent(k-1), ...
            dt,Battery.DesignCapacity);
    end

    [CellVoltage(k),Vrc,OCV(k),Status] = batteryECM( ...
        SOC(k),CellCurrent(k),Vrc,dt,Battery);

    PackVoltage(k) = CellVoltage(k)*Pack.Ns;
    OverVoltage(k) = Status.OverVoltage;
    UnderVoltage(k) = Status.UnderVoltage;
end

fprintf('\n====================================================\n');
fprintf('             Dynamic 1RC ECM Simulation\n');
fprintf('====================================================\n');
fprintf('Reference pack       : %s (%d cells)\n',Pack.Configuration,Pack.TotalCells);
fprintf('Cell model           : %s\n',Battery.CellModel);
fprintf('Initial SOC          : %.4f\n',SOC(1));
fprintf('Final SOC            : %.4f\n',SOC(end));
fprintf('Simulation time      : %.1f s\n',T_end);
fprintf('Time step            : %.2f s\n',dt);
fprintf('Pack current range   : %.2f to %.2f A\n', ...
    min(PackCurrent),max(PackCurrent));
fprintf('Cell current range   : %.2f to %.2f A\n', ...
    min(CellCurrent),max(CellCurrent));
fprintf('Configured cell max discharge current: %.2f A\n', ...
    Battery.MaxDischargeCurrent);
fprintf('Overvoltage samples  : %d\n',sum(OverVoltage));
fprintf('Undervoltage samples : %d\n',sum(UnderVoltage));
fprintf('Pack voltage range   : %.2f to %.2f V\n', ...
    min(PackVoltage),max(PackVoltage));
fprintf('====================================================\n');

resultsFolder = fullfile(fileparts(mfilename('fullpath')),'Results');
if ~isfolder(resultsFolder), mkdir(resultsFolder); end

fig = figure('Name','Pack Current Profile');
plot(t,PackCurrent,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('Pack Current (A)');
title('Synthetic Pack Current Profile — 13S6P');
saveas(fig,fullfile(resultsFolder,'Dynamic_ECM_Current Profile.png'));

fig = figure('Name','Cell Current Profile');
plot(t,CellCurrent,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('Cell Current (A)');
title('Per-Cell Current (Pack Current / Parallel Cell Count)');
saveas(fig,fullfile(resultsFolder,'Dynamic_ECM_Cell Current Profile.png'));

fig = figure('Name','Cell Terminal Voltage');
plot(t,CellVoltage,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('Cell Voltage (V)');
title('Reference Cell Terminal Voltage — 1RC ECM');
saveas(fig,fullfile(resultsFolder,'Dynamic_ECM_Cell Terminal Voltage.png'));

fig = figure('Name','Pack Terminal Voltage');
plot(t,PackVoltage,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('Pack Voltage (V)');
title('13S6P Pack Terminal Voltage — 1RC Cell Model');
saveas(fig,fullfile(resultsFolder,'Dynamic_ECM_Terminal Voltage.png'));

fig = figure('Name','Pack Open Circuit Voltage');
plot(t,OCV*Pack.Ns,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('Pack OCV (V)');
title('13S6P Pack Open-Circuit Voltage');
saveas(fig,fullfile(resultsFolder,'Dynamic_ECM_Open Circuit Voltage.png'));

fig = figure('Name','State of Charge');
plot(t,SOC,'LineWidth',2); grid on;
xlabel('Time (s)'); ylabel('SOC (fraction)');
title('Pack State of Charge — Coulomb Counting');
ylim([0 1]);
saveas(fig,fullfile(resultsFolder,'Dynamic_ECM_State of Charge.png'));

summaryFile = fullfile(resultsFolder,'Dynamic_ECM_Simulation result.txt');
fid = fopen(summaryFile,'w');
if fid < 0
    warning('BMS:SummaryFileWriteFailed','Could not write simulation summary: %s',summaryFile);
else
    fprintf(fid,'Dynamic 1RC ECM Simulation\n');
    fprintf(fid,'Pack configuration: %s\n',Pack.Configuration);
    fprintf(fid,'Initial SOC: %.6f\n',SOC(1));
    fprintf(fid,'Final SOC: %.6f\n',SOC(end));
    fprintf(fid,'Pack current range (A): %.6f to %.6f\n',min(PackCurrent),max(PackCurrent));
    fprintf(fid,'Cell current range (A): %.6f to %.6f\n',min(CellCurrent),max(CellCurrent));
    fprintf(fid,'Pack voltage range (V): %.6f to %.6f\n',min(PackVoltage),max(PackVoltage));
    fprintf(fid,'Overvoltage samples: %d\n',sum(OverVoltage));
    fprintf(fid,'Undervoltage samples: %d\n',sum(UnderVoltage));
    fclose(fid);
end
