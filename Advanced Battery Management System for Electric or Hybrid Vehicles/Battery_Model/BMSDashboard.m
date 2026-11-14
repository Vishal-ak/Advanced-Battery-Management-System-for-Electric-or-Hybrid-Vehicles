function BMSDashboard()
%BMSDASHBOARD Interactive simulation and monitoring dashboard for the MATLAB BMS.
% Launch from the canonical Battery_Model folder:
%   setupProject();
%   BMSDashboard
%
% This application visualizes simulated cell behaviour. It is not a live
% hardware telemetry interface and is not a safety-qualified BMS.

projectRoot = fileparts(mfilename('fullpath'));
if isempty(projectRoot), projectRoot = pwd; end
addpath(projectRoot);
setupProject();
Battery = initBattery();
lastResult = [];

fig = uifigure('Name','Advanced Battery Management System | Monitoring Dashboard', ...
    'Position',[80 60 1420 880], 'Color',[0.96 0.97 0.98]);
main = uigridlayout(fig,[1 2]);
main.ColumnWidth = {300,'1x'};
main.Padding = [12 12 12 12];
main.ColumnSpacing = 12;

% -------------------- Left control panel --------------------
left = uipanel(main,'Title','Simulation Controls');
left.Layout.Row = 1; left.Layout.Column = 1;
g = uigridlayout(left,[16 2]);
g.ColumnWidth = {112,'1x'};
g.RowHeight = {28,28,28,28,28,28,28,28,28,28,34,34,34,34,34,'1x'};
g.Padding = [10 10 10 10];
g.ColumnSpacing = 8;

uilabel(g,'Text','ECM model'); 
modelDrop = uidropdown(g,'Items',{'1RC Thevenin','2RC Thevenin'},'Value','1RC Thevenin');
uilabel(g,'Text','Current profile');
profileDrop = uidropdown(g,'Items',{'Constant','Step','Pulse','Synthetic dynamic'},'Value','Constant');
uilabel(g,'Text','Current (A)');
currentField = uieditfield(g,'numeric','Value',2,'Limits',[-5 5]);
uilabel(g,'Text','Initial SOC (%)');
socField = uieditfield(g,'numeric','Value',100,'Limits',[0 100]);
uilabel(g,'Text','Duration (s)');
durationField = uieditfield(g,'numeric','Value',300,'Limits',[1 20000],'RoundFractionalValues','on');
uilabel(g,'Text','Time step (s)');
dtField = uieditfield(g,'numeric','Value',1,'Limits',[0.1 10]);
uilabel(g,'Text','Ambient (°C)');
ambientField = uieditfield(g,'numeric','Value',25,'Limits',[-20 60]);
uilabel(g,'Text','Pack series Ns');
nsField = uieditfield(g,'numeric','Value',13,'Limits',[1 300],'RoundFractionalValues','on');
uilabel(g,'Text','Pack parallel Np');
npField = uieditfield(g,'numeric','Value',6,'Limits',[1 300],'RoundFractionalValues','on');

runBtn = uibutton(g,'Text','Run simulation','ButtonPushedFcn',@runSimulation);
runBtn.Layout.Row = 10; runBtn.Layout.Column = [1 2];
resetBtn = uibutton(g,'Text','Reset dashboard','ButtonPushedFcn',@resetDashboard);
resetBtn.Layout.Row = 11; resetBtn.Layout.Column = [1 2];
exportBtn = uibutton(g,'Text','Export CSV data','ButtonPushedFcn',@exportCSV);
exportBtn.Layout.Row = 12; exportBtn.Layout.Column = [1 2];
pngBtn = uibutton(g,'Text','Export plots (PNG + FIG)','ButtonPushedFcn',@exportPlots);
pngBtn.Layout.Row = 13; pngBtn.Layout.Column = [1 2];
packBtn = uibutton(g,'Text','Calculate pack sizing','ButtonPushedFcn',@calculatePack);
packBtn.Layout.Row = 14; packBtn.Layout.Column = [1 2];

note = uitextarea(g,'Editable','off','Value', ...
    {'Simulation-only monitoring.','Positive current = discharge.','Synthetic dynamic profile is illustrative.','Cell parameters include provisional assumptions.'});
note.Layout.Row = 15; note.Layout.Column = [1 2];

% -------------------- Main display --------------------
right = uigridlayout(main,[3 1]);
right.Layout.Row = 1; right.Layout.Column = 2;
right.RowHeight = {78,'1x',125};
right.Padding = [0 0 0 0];
metrics = uigridlayout(right,[1 5]);
metrics.Layout.Row = 1;
metrics.ColumnWidth = {'1x','1x','1x','1x','1x'};
metrics.ColumnSpacing = 8;
socMetric = metricCard(metrics,'SOC','-- %');
voltageMetric = metricCard(metrics,'Cell voltage','-- V');
currentMetric = metricCard(metrics,'Current','-- A');
tempMetric = metricCard(metrics,'Temperature','-- °C');
statusMetric = metricCard(metrics,'BMS status','NOT RUN');

tabs = uitabgroup(right);
tabs.Layout.Row = 2;
monitorTab = uitab(tabs,'Title','Live Simulation View');
packTab = uitab(tabs,'Title','Pack & Cell Information');
resultsTab = uitab(tabs,'Title','Results Data');

plotGrid = uigridlayout(monitorTab,[2 2]);
plotGrid.RowHeight = {'1x','1x'};
plotGrid.ColumnWidth = {'1x','1x'};
plotGrid.Padding = [8 8 8 8];
axV = uiaxes(plotGrid); title(axV,'Terminal voltage'); xlabel(axV,'Time (s)'); ylabel(axV,'Voltage (V)'); grid(axV,'on');
axSOC = uiaxes(plotGrid); title(axSOC,'State of charge'); xlabel(axSOC,'Time (s)'); ylabel(axSOC,'SOC (%)'); grid(axSOC,'on');
axI = uiaxes(plotGrid); title(axI,'Applied current'); xlabel(axI,'Time (s)'); ylabel(axI,'Current (A)'); grid(axI,'on');
axT = uiaxes(plotGrid); title(axT,'Cell temperature'); xlabel(axT,'Time (s)'); ylabel(axT,'Temperature (°C)'); grid(axT,'on');

packGrid = uigridlayout(packTab,[2 2]);
packGrid.RowHeight = {'1x','1x'}; packGrid.ColumnWidth = {'1x','1x'};
cellInfo = uitextarea(packGrid,'Editable','off');
cellInfo.Value = {char(Battery.CellModel),sprintf('Chemistry: %s',Battery.Chemistry), ...
    sprintf('Nominal voltage: %.2f V',Battery.NominalVoltage), ...
    sprintf('Typical capacity: %.2f Ah',Battery.TypicalCapacity), ...
    sprintf('Maximum voltage: %.2f V',Battery.MaximumVoltage), ...
    sprintf('Cutoff voltage: %.2f V',Battery.CutoffVoltage), ...
    sprintf('R0 / R1 / C1: %.4f ohm / %.4f ohm / %.0f F',Battery.R0,Battery.R1,Battery.C1), ...
    sprintf('R2 / C2: %.4f ohm / %.0f F',Battery.R2,Battery.C2), ...
    sprintf('OCV data status: %s',char(Battery.OCVDataStatus))};
cellInfo.Layout.Row = [1 2]; cellInfo.Layout.Column = 1;
packInfo = uitextarea(packGrid,'Editable','off','Value', ...
    {'Pack sizing has not been calculated.','Set Ns and Np on the left, then select Calculate pack sizing.'});
packInfo.Layout.Row = [1 2]; packInfo.Layout.Column = 2;

resultGrid = uigridlayout(resultsTab,[1 1]);
resultGrid.Padding = [8 8 8 8];
dataTable = uitable(resultGrid);
dataTable.ColumnName = {'Time_s','Current_A','SOC','OCV_V','TerminalVoltage_V','Temperature_C','Status'};

footer = uitextarea(right,'Editable','off','Value', ...
    {'Ready. Run a simulation to populate the plots and results table.', ...
     'Engineering note: no measured-cell validation or hardware telemetry is represented.'});
footer.Layout.Row = 3;

% Initial axes state
cla(axV); cla(axSOC); cla(axI); cla(axT);

    function card = metricCard(parent,heading,value)
        card = uipanel(parent,'Title',heading);
        cg = uigridlayout(card,[1 1]); cg.Padding = [4 4 4 4];
        lbl = uilabel(cg,'Text',value,'FontSize',18,'FontWeight','bold','HorizontalAlignment','center');
        card.UserData = lbl;
    end

    function setMetric(card,value)
        metricLabel = card.UserData;
        metricLabel.Text = value;
    end

    function runSimulation(~,~)
        try
            duration = durationField.Value;
            dt = dtField.Value;
            if duration <= 0 || dt <= 0, error('Duration and time step must be positive.'); end
            t = (0:dt:duration)';
            n = numel(t);
            I = makeCurrent(t);
            soc = zeros(n,1); ocv = zeros(n,1); vt = zeros(n,1); temp = zeros(n,1);
            status = strings(n,1);
            soc(1) = socField.Value/100;
            temp(1) = ambientField.Value;
            vrc1 = 0; vrc2 = 0;
            for k = 1:n
                if k > 1
                    soc(k) = coulombCounting(soc(k-1),I(k-1),dt,Battery.DesignCapacity);
                    heat = calcHeatGeneration(I(k-1),Battery);
                    temp(k) = updateTemperature(temp(k-1),heat,ambientField.Value,dt,Battery);
                end
                if modelDrop.Value == "1RC Thevenin"
                    [vt(k),vrc1,ocv(k),st] = batteryECM(soc(k),I(k),vrc1,dt,Battery);
                else
                    [vt(k),vrc1,vrc2,ocv(k),st] = batteryECM_2RC(soc(k),I(k),vrc1,vrc2,dt,Battery);
                end
                if st.OverVoltage || st.UnderVoltage
                    status(k) = "VOLTAGE LIMIT";
                elseif temp(k) > Battery.MaxCellTemperature || temp(k) < Battery.MinCellTemperature
                    status(k) = "TEMPERATURE LIMIT";
                elseif abs(I(k)) > Battery.MaxDischargeCurrent
                    status(k) = "CURRENT LIMIT";
                else
                    status(k) = "NORMAL";
                end
            end
            lastResult = table(t,I,soc,ocv,vt,temp,status, ...
                'VariableNames',{'Time_s','Current_A','SOC','OCV_V','TerminalVoltage_V','Temperature_C','Status'});
            dataTable.Data = lastResult;
            plot(axV,t,vt,'LineWidth',1.4); hold(axV,'on'); plot(axV,t,ocv,'--','LineWidth',1.1); hold(axV,'off');
            legend(axV,{'Terminal voltage','OCV'},'Location','best');
            plot(axSOC,t,100*soc,'LineWidth',1.4);
            plot(axI,t,I,'LineWidth',1.2);
            plot(axT,t,temp,'LineWidth',1.4);
            setMetric(socMetric,sprintf('%.1f %%',100*soc(end)));
            setMetric(voltageMetric,sprintf('%.3f V',vt(end)));
            setMetric(currentMetric,sprintf('%.2f A',I(end)));
            setMetric(tempMetric,sprintf('%.2f °C',temp(end)));
            if any(status ~= "NORMAL")
                setMetric(statusMetric,'CHECK LIMITS');
            else
                setMetric(statusMetric,'NORMAL');
            end
            footer.Value = {sprintf('Simulation complete: %d samples, %.1f s, dt %.2f s.',n,duration,dt), ...
                sprintf('Model: %s | Profile: %s',modelDrop.Value,profileDrop.Value), ...
                sprintf('Final SOC %.2f %% | Final voltage %.3f V | Peak temperature %.2f °C.', ...
                100*soc(end),vt(end),max(temp)), ...
                'Status flags are simplified simulation indicators, not certified protection logic.'};
            tabs.SelectedTab = monitorTab;
        catch ME
            uialert(fig,ME.message,'Simulation error');
        end
    end

    function I = makeCurrent(t)
        switch profileDrop.Value
            case 'Constant'
                I = currentField.Value*ones(size(t));
            case 'Step'
                I = currentField.Value*ones(size(t));
                I(t >= 0.35*t(end)) = 0.5*currentField.Value;
            case 'Pulse'
                I = zeros(size(t));
                I(mod(floor(t/20),2)==0) = currentField.Value;
            otherwise
                % Existing driveCycleCurrent is a synthetic pack-like profile.
                % Scale it for a single-cell simulation and keep within the
                % provisional 5 A cell-current assumption.
                I = 0.1*driveCycleCurrent(t);
                I = max(-Battery.MaxDischargeCurrent,min(Battery.MaxDischargeCurrent,I));
        end
    end

    function calculatePack(~,~)
        try
            Pack = createBatteryPack(Battery,round(nsField.Value),round(npField.Value),false);
            packInfo.Value = {sprintf('Configuration: %s',Pack.Configuration), ...
                sprintf('Total cells: %d',Pack.TotalCells), ...
                sprintf('Nominal voltage: %.2f V',Pack.NominalVoltage), ...
                sprintf('Voltage range: %.2f to %.2f V',Pack.CutoffVoltage,Pack.MaximumVoltage), ...
                sprintf('Capacity: %.2f Ah',Pack.Capacity), ...
                sprintf('Energy: %.2f Wh',Pack.Energy_Wh), ...
                sprintf('Estimated total mass: %.3f kg',Pack.Mass), ...
                sprintf('Specific energy: %.1f Wh/kg',Pack.SpecificEnergy_Whkg), ...
                sprintf('Cell-envelope volume only: %.3f L',Pack.Volume_L), ...
                'Volume excludes enclosure, cooling and interconnect packaging.', ...
                'Mass and cost inputs are estimates, not measured pack values.'};
            tabs.SelectedTab = packTab;
        catch ME
            uialert(fig,ME.message,'Pack sizing error');
        end
    end

    function exportCSV(~,~)
        if isempty(lastResult), uialert(fig,'Run a simulation before exporting.','No results'); return; end
        outDir = fullfile(projectRoot,'Results','Dashboard');
        if ~isfolder(outDir), mkdir(outDir); end
        [file,path] = uiputfile(fullfile(outDir,'BMS_Simulation.csv'),'Export simulation data');
        if isequal(file,0), return; end
        writetable(lastResult,fullfile(path,file));
        footer.Value = {sprintf('CSV exported: %s',fullfile(path,file))};
    end

    function exportPlots(~,~)
        if isempty(lastResult), uialert(fig,'Run a simulation before exporting plots.','No results'); return; end
        outDir = fullfile(projectRoot,'Results','Dashboard');
        if ~isfolder(outDir), mkdir(outDir); end
        % Export a standalone MATLAB figure so PNG and editable FIG output
        % are consistent across MATLAB Online releases.
        f = figure('Visible','off','Color','w');
        tiledlayout(f,2,2);
        a1=nexttile; plot(a1,lastResult.Time_s,lastResult.TerminalVoltage_V); hold(a1,'on'); plot(a1,lastResult.Time_s,lastResult.OCV_V,'--'); title(a1,'Voltage'); xlabel(a1,'Time (s)'); ylabel(a1,'V'); grid(a1,'on');
        a2=nexttile; plot(a2,lastResult.Time_s,100*lastResult.SOC); title(a2,'SOC'); xlabel(a2,'Time (s)'); ylabel(a2,'%'); grid(a2,'on');
        a3=nexttile; plot(a3,lastResult.Time_s,lastResult.Current_A); title(a3,'Current'); xlabel(a3,'Time (s)'); ylabel(a3,'A'); grid(a3,'on');
        a4=nexttile; plot(a4,lastResult.Time_s,lastResult.Temperature_C); title(a4,'Temperature'); xlabel(a4,'Time (s)'); ylabel(a4,'°C'); grid(a4,'on');
        saveBMSFigure(f,projectRoot,'Dashboard','BMS_Dashboard_Results');
        close(f);
        footer.Value = {'Plots exported to Results/Dashboard as PNG and editable FIG.'};
    end

    function resetDashboard(~,~)
        lastResult = [];
        dataTable.Data = {};
        cla(axV); cla(axSOC); cla(axI); cla(axT);
        setMetric(socMetric,'-- %'); setMetric(voltageMetric,'-- V');
        setMetric(currentMetric,'-- A'); setMetric(tempMetric,'-- °C');
        setMetric(statusMetric,'NOT RUN');
        footer.Value = {'Dashboard reset. Configure the simulation and select Run simulation.'};
    end
end
