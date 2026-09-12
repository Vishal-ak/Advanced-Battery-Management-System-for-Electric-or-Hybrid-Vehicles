function Report = BatteryDesigner(targetVoltage,targetCapacity)
%===========================================================
% ADVANCED BATTERY DESIGN PLATFORM
%
% Features
% --------
% 1. Commercial Battery Recommendation
% 2. Custom Battery Pack Design
% 3. Battery Pack Validation
% 4. Commercial vs Custom Comparison
% 5. Final Recommendation
%===========================================================

clc

fprintf("\n");
fprintf("=====================================================\n");
fprintf(" ADVANCED BATTERY DESIGN PLATFORM\n");
fprintf("=====================================================\n");

%% Design Requirements

fprintf("\nDesign Requirements\n");
fprintf("-----------------------------\n");

fprintf("Voltage : %.2f V\n",targetVoltage);
fprintf("Capacity: %.2f Ah\n",targetCapacity);

%% Commercial Battery

Commercial = recommendPack( ...
    targetVoltage,...
    targetCapacity,...
    1);

%% Custom Battery

Custom = designPack( ...
    targetVoltage,...
    targetCapacity);

%% Validate Custom Pack

Validation = validatePack(Custom);

%% Commercial Energy

CommercialEnergy = ...
    Commercial.NominalVoltage_V .* ...
    Commercial.NominalCapacity_Ah;

%% Comparison

fprintf("\n");
fprintf("=====================================================\n");
fprintf(" COMPARISON\n");
fprintf("=====================================================\n");

fprintf("%-25s %-15s %-15s\n",...
    "Parameter","Commercial","Custom");

fprintf("-----------------------------------------------------\n");

fprintf("%-25s %-15s %-15s\n",...
    "Configuration",...
    Commercial.Configuration{1},...
    Custom.Configuration);

fprintf("%-25s %-15.2f %-15.2f\n",...
    "Voltage (V)",...
    Commercial.NominalVoltage_V,...
    Custom.NominalVoltage);

fprintf("%-25s %-15.2f %-15.2f\n",...
    "Capacity (Ah)",...
    Commercial.NominalCapacity_Ah,...
    Custom.Capacity);

fprintf("%-25s %-15.2f %-15.2f\n",...
    "Energy (Wh)",...
    CommercialEnergy,...
    Custom.Energy_Wh);

fprintf("%-25s %-15.2f %-15.2f\n",...
    "Weight (kg)",...
    Commercial.Weight_kg,...
    Custom.Mass);

fprintf("%-25s %-15d %-15d\n",...
    "Total Cells",...
    Commercial.TotalCells,...
    Custom.TotalCells);

fprintf("%-25s %-15.2f %-15.2f\n",...
    "Specific Energy",...
    Commercial.SpecificEnergy_Whkg,...
    Custom.SpecificEnergy_Whkg);

fprintf("%-25s %-15.2f %-15.2f\n",...
    "Energy Density",...
    Commercial.VolumetricEnergy_WhL,...
    Custom.EnergyDensity_WhL);

fprintf("%-25s %-15s ₹%-14.0f\n",...
    "Estimated Cost",...
    "N/A",...
    Custom.EstimatedCost);

%% Recommendation

CommercialScore = ...
    abs(Commercial.NominalVoltage_V-targetVoltage)/targetVoltage + ...
    abs(Commercial.NominalCapacity_Ah-targetCapacity)/targetCapacity;

CustomScore = ...
    abs(Custom.NominalVoltage-targetVoltage)/targetVoltage + ...
    abs(Custom.Capacity-targetCapacity)/targetCapacity;

fprintf("\n");
fprintf("=====================================================\n");
fprintf(" FINAL RECOMMENDATION\n");
fprintf("=====================================================\n");

if CustomScore < CommercialScore

    fprintf("Recommended : CUSTOM BATTERY PACK\n");
    fprintf("Reason      : Better voltage/capacity match.\n");

elseif CommercialScore < CustomScore

    fprintf("Recommended : COMMERCIAL BATTERY PACK\n");
    fprintf("Reason      : Better voltage/capacity match.\n");

else

    if Custom.Mass < Commercial.Weight_kg

        fprintf("Recommended : CUSTOM BATTERY PACK\n");
        fprintf("Reason      : Similar performance with lower weight.\n");

    else

        fprintf("Recommended : COMMERCIAL BATTERY PACK\n");
        fprintf("Reason      : Similar performance.\n");

    end

end

%% Validation Status

fprintf("\n");
fprintf("=====================================================\n");
fprintf(" VALIDATION STATUS\n");
fprintf("=====================================================\n");

if Validation.IsValid

    fprintf("Status   : PASSED\n");

else

    fprintf("Status   : FAILED\n");

end

fprintf("Warnings : %d\n",numel(Validation.Warnings));
fprintf("Errors   : %d\n",numel(Validation.Errors));

%% Output Report

Report.Requirement.Voltage = targetVoltage;
Report.Requirement.Capacity = targetCapacity;

Report.Commercial = Commercial;
Report.Custom = Custom;

Report.Validation = Validation;

end