function app = BMSDashboard()
% BMSDASHBOARD Interactive MATLAB dashboard for the educational BMS model.
% Launch from the canonical Battery_Model folder with:
%   app = BMSDashboard();
%
% The dashboard calls simulateBatteryPack, which in turn calls the project's
% ECM, Coulomb-counting and lumped thermal functions. It is not a live BMS,
% a hardware interface, a certified protection system or a vehicle simulator.

% Configure canonical source paths so the dashboard can be launched directly.
setupProject();
Battery = initBattery();

fig = uifigure('Name','Advanced Battery Management System — Simulation Dashboard', ...
    'Position',[80 60 1280 900]);
fig.Color = [0.96 0.97 0.98];

root = uigridlayout(fig,[4 1]);
root.RowHeight = {178,'1x',82,26};
root.Padding = [12 12 12 12];
root.RowSpacing = 9;

%% Configuration controls
controlPanel = uipanel(root,'Title','Simulation Configuration');
controlPanel.Layout.Row = 1;
controlGrid = uigridlayout(controlPanel,[5 4]);
controlGrid.RowHeight = {22,30,22,30,34};
controlGrid.ColumnWidth = {'1x','1x','1x','1x'};
controlGrid.Padding = [8 8 8 8];
controlGrid.RowSpacing = 3;
controlGrid.ColumnSpacing = 12;

addLabel(controlGrid,'Series cells (Ns)',1,1);
addLabel(controlGrid,'Parallel strings (Np)',1,2);
addLabel(controlGrid,'Initial SOC (fraction)',1,3);
addLabel(controlGrid,'Initial cell temperature (°C)',1,4);

nsField = uieditfield(controlGrid,'numeric','Value',13,'Limits',[1 300], ...
    'RoundFractionalValues','on');
nsField.Layout.Row = 2; nsField.Layout.Column = 1;

npField = uieditfield(controlGrid,'numeric','Value',6,'Limits',[1 300], ...
    'RoundFractionalValues','on');
npField.Layout.Row = 2; npField.Layout.Column = 2;

socField = uieditfield(controlGrid,'numeric','Value',0.80,'Limits',[0.10 1.00]);
socField.Layout.Row = 2; socField.Layout.Column = 3;

initialTempField = uieditfield(controlGrid,'numeric','Value',25,'Limits',[-20 60]);
initialTempField.Layout.Row = 2; initialTempField.Layout.Column = 4;

addLabel(controlGrid,'Pack current profile',3,1);
addLabel(controlGrid,'Ambient temperature (°C)',3,2);
addLabel(controlGrid,'Time step (s)',3,3);
addLabel(controlGrid,'Duration (s)',3,4);

profileField = uidropdown(controlGrid, ...
    'Items',{'Synthetic drive cycle','Constant discharge','Constant charge','Step discharge','Pulse discharge'}, ...
    'Value','Synthetic drive cycle');
profileField.Layout.Row = 4; profileField.Layout.Column = 1;

ambientField = uieditfield(controlGrid,'numeric','Value',25,'Limits',[-20 60]);
ambientField.Layout.Row = 4; ambientField.Layout.Column = 2;

dtField = uieditfield(controlGrid,'numeric','Value',1,'Limits',[0.1 10]);
dtField.Layout.Row = 4; dtField.Layout.Column = 3;

durationField = uieditfield(controlGrid,'numeric','Value',300,'Limits',[10 3600]);
durationField.Layout.Row = 4; durationField.Layout.Column = 4;

runButton = uibutton(controlGrid,'push','Text','Run simulation', ...
    'FontWeight','bold','ButtonPushedFcn',@runSimulation);
runButton.Layout.Row = 5; runButton.Layout.Column = 1;

exportButton = uibutton(controlGrid,'push','Text','Export results (CSV)', ...
    'Enable','off','ButtonPushedFcn',@exportResults);
exportButton.Layout.Row = 5; exportButton.Layout.Column = 2;

configNote = uilabel(controlGrid,'Text', ...
    'Current profiles are scaled to configured per-cell limits.', ...
    'FontColor',[0.28 0.32 0.38]);
configNote.Layout.Row = 5; configNote.Layout.Column = [3 4];

%% Plots
plotPanel = uipanel(root,'Title','Model Outputs');
plotPanel.Layout.Row = 2;
plotGrid = uigridlayout(plotPanel,[2 2]);
plotGrid.RowHeight = {'1x','1x'};
plotGrid.ColumnWidth = {'1x','1x'};
plotGrid.Padding = [8 8 8 8];
plotGrid.RowSpacing = 8;
plotGrid.ColumnSpacing = 10;

axCurrent = uiaxes(plotGrid);
axCurrent.Layout.Row = 1; axCurrent.Layout.Column = 1;
title(axCurrent,'Current'); xlabel(axCurrent,'Time (s)');
ylabel(axCurrent,'Current (A)'); grid(axCurrent,'on');

axVoltage = uiaxes(plotGrid);
axVoltage.Layout.Row = 1; axVoltage.Layout.Column = 2;
title(axVoltage,'Pack terminal voltage'); xlabel(axVoltage,'Time (s)');
ylabel(axVoltage,'Voltage (V)'); grid(axVoltage,'on');

axSOC = uiaxes(plotGrid);
axSOC.Layout.Row = 2; axSOC.Layout.Column = 1;
title(axSOC,'State of charge'); xlabel(axSOC,'Time (s)');
ylabel(axSOC,'SOC (fraction)'); ylim(axSOC,[0 1]); grid(axSOC,'on');

axTemperature = uiaxes(plotGrid);
axTemperature.Layout.Row = 2; axTemperature.Layout.Column = 2;
title(axTemperature,'Cell temperature'); xlabel(axTemperature,'Time (s)');
ylabel(axTemperature,'Temperature (°C)'); grid(axTemperature,'on');

%% Summary metrics
summaryPanel = uipanel(root,'Title','Run Summary');
summaryPanel.Layout.Row = 3;
summaryGrid = uigridlayout(summaryPanel,[2 4]);
summaryGrid.RowHeight = {'1x','1x'};
summaryGrid.ColumnWidth = {'1x','1x','1x','1x'};
summaryGrid.Padding = [8 4 8 4];

socMetric = summaryLabel(summaryGrid,'SOC: —',1,1);
voltageMetric = summaryLabel(summaryGrid,'Pack voltage: —',1,2);
temperatureMetric = summaryLabel(summaryGrid,'Peak cell temperature: —',1,3);
currentMetric = summaryLabel(summaryGrid,'Cell current: —',1,4);
packMetric = summaryLabel(summaryGrid,'Pack: —',2,1);
inhibitionMetric = summaryLabel(summaryGrid,'Current inhibition: —',2,2);
voltageFlagMetric = summaryLabel(summaryGrid,'Voltage flags: —',2,3);
methodMetric = summaryLabel(summaryGrid,'SOC method: Coulomb counting',2,4);

statusLabel = uilabel(root,'Text', ...
    'Ready. This is a simulation dashboard, not a live hardware BMS.', ...
    'FontColor',[0.22 0.28 0.34]);
statusLabel.Layout.Row = 4;

lastResults = [];
app = struct('Figure',fig,'Battery',Battery, ...
    'RunButton',runButton,'ExportButton',exportButton, ...
    'SeriesCellsField',nsField,'ParallelStringsField',npField, ...
    'InitialSOCField',socField,'ProfileField',profileField, ...
    'GetResults',@getResults);

%% Nested callbacks
    function runSimulation(~,~)
        runButton.Enable = 'off';
        exportButton.Enable = 'off';
        lastResults = [];
        fig.UserData = [];
        statusLabel.Text = 'Running model...';
        drawnow;

        try
            Ns = round(nsField.Value);
            Np = round(npField.Value);
            if Ns < 1 || Np < 1
                error('BMS:InvalidConfiguration','Ns and Np must be positive integers.');
            end
            Pack = createBatteryPack(Battery,Ns,Np,false);
            result = simulateBatteryPack(Battery,Pack, ...
                socField.Value,initialTempField.Value,ambientField.Value, ...
                dtField.Value,durationField.Value,profileField.Value);

            cla(axCurrent);
            plot(axCurrent,result.Time_s,result.PackCurrent_A,'LineWidth',1.5);
            hold(axCurrent,'on');
            plot(axCurrent,result.Time_s,result.CellCurrent_A,'LineWidth',1.2);
            hold(axCurrent,'off');
            legend(axCurrent,{'Pack current','Cell current'},'Location','best');
            title(axCurrent,'Applied current'); xlabel(axCurrent,'Time (s)');
            ylabel(axCurrent,'Current (A)'); grid(axCurrent,'on');

            cla(axVoltage);
            plot(axVoltage,result.Time_s,result.PackTerminalVoltage_V,'LineWidth',1.5);
            hold(axVoltage,'on');
            yline(axVoltage,Pack.MaximumVoltage,'--','Max voltage');
            yline(axVoltage,Pack.CutoffVoltage,'--','Cutoff voltage');
            hold(axVoltage,'off');
            title(axVoltage,'Pack terminal voltage (Ns × cell voltage)');
            xlabel(axVoltage,'Time (s)'); ylabel(axVoltage,'Voltage (V)');
            grid(axVoltage,'on');

            cla(axSOC);
            plot(axSOC,result.Time_s,result.SOC,'LineWidth',1.5);
            title(axSOC,'Coulomb-counting SOC');
            xlabel(axSOC,'Time (s)'); ylabel(axSOC,'SOC (fraction)');
            ylim(axSOC,[0 1]); grid(axSOC,'on');

            cla(axTemperature);
            plot(axTemperature,result.Time_s,result.CellTemperature_C,'LineWidth',1.5);
            hold(axTemperature,'on');
            yline(axTemperature,Battery.MaxCellTemperature,'--','Configured max');
            hold(axTemperature,'off');
            title(axTemperature,'Single-cell lumped thermal model');
            xlabel(axTemperature,'Time (s)'); ylabel(axTemperature,'Temperature (°C)');
            grid(axTemperature,'on');

            socMetric.Text = sprintf('SOC: %.1f%% → %.1f%%', ...
                100*result.SOC(1),100*result.SOC(end));
            voltageMetric.Text = sprintf('Pack voltage: %.1f–%.1f V', ...
                min(result.PackTerminalVoltage_V),max(result.PackTerminalVoltage_V));
            temperatureMetric.Text = sprintf('Peak cell temperature: %.1f °C', ...
                max(result.CellTemperature_C));
            currentMetric.Text = sprintf('Cell current: %.2f to %.2f A', ...
                min(result.CellCurrent_A),max(result.CellCurrent_A));
            packMetric.Text = sprintf('Pack: %s (%d cells)', ...
                Pack.Configuration,Pack.TotalCells);
            inhibitionMetric.Text = sprintf('Inhibited / derated / SOC-limited: %d / %d / %d', ...
                result.ChargeInhibitionCount+result.DischargeInhibitionCount, ...
                result.ChargeDeratingCount,result.SOCBoundaryLimitCount);
            voltageFlagMetric.Text = sprintf('Voltage flags: %d samples', ...
                result.VoltageLimitViolationCount);
            methodMetric.Text = 'SOC method: Coulomb counting';

            warningText = '';
            if result.VoltageLimitViolationCount > 0
                warningText = sprintf(' WARNING: %d voltage-limit samples.', ...
                    result.VoltageLimitViolationCount);
            end
            if result.ChargeInhibitionCount+result.DischargeInhibitionCount > 0
                warningText = [warningText sprintf( ...
                    ' %d current samples inhibited by model limits.', ...
                    result.ChargeInhibitionCount+result.DischargeInhibitionCount)];
            end
            statusLabel.Text = sprintf( ...
                'Completed: %s | N=%d, dt=%.2f s.%s', ...
                result.ProfileName,numel(result.Time_s),dtField.Value,warningText);

            lastResults = result;
            fig.UserData = result;
            exportButton.Enable = 'on';
        catch ME
            statusLabel.Text = ['Simulation failed: ' ME.message];
            uialert(fig,ME.message,'Simulation error','Icon','error');
        end
        runButton.Enable = 'on';
    end

    function result = getResults()
        result = lastResults;
    end

    function exportResults(~,~)
        if isempty(lastResults)
            uialert(fig,'Run a simulation before exporting.','No results');
            return;
        end
        [file,pathName] = uiputfile('BMS_Simulation_Results.csv', ...
            'Export simulation results');
        if isequal(file,0)
            return;
        end
        R = lastResults;
        outputTable = table(R.Time_s,R.RawPackCurrent_A, ...
            R.CommandPackCurrent_A,R.PackCurrent_A,R.CellCurrent_A, ...
            R.CellTerminalVoltage_V,R.PackTerminalVoltage_V, ...
            R.CellOCV_V,R.PackOCV_V,R.SOC,R.CellTemperature_C, ...
            R.OverVoltage,R.UnderVoltage,R.ChargeInhibited, ...
            R.DischargeInhibited,R.ChargeCurrentDerated,R.SOCBoundaryLimited, ...
            'VariableNames',{'Time_s','RawPackCurrent_A', ...
            'CommandPackCurrent_A','AppliedPackCurrent_A','CellCurrent_A', ...
            'CellTerminalVoltage_V','PackTerminalVoltage_V', ...
            'CellOCV_V','PackOCV_V','SOC','CellTemperature_C', ...
            'OverVoltage','UnderVoltage','ChargeInhibited', ...
            'DischargeInhibited','ChargeCurrentDerated','SOCBoundaryLimited'});
        try
            writetable(outputTable,fullfile(pathName,file));
            statusLabel.Text = ['CSV exported: ' fullfile(pathName,file)];
        catch ME
            uialert(fig,ME.message,'Export error','Icon','error');
        end
    end
end

function addLabel(parent,textValue,row,column)
label = uilabel(parent,'Text',textValue,'FontWeight','bold');
label.Layout.Row = row;
label.Layout.Column = column;
end

function label = summaryLabel(parent,textValue,row,column)
label = uilabel(parent,'Text',textValue,'FontWeight','bold', ...
    'HorizontalAlignment','center');
label.Layout.Row = row;
label.Layout.Column = column;
end
