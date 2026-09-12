function Result = validatePack(Pack)
%===========================================================
% VALIDATE BATTERY PACK
%
% Performs engineering validation of a battery pack.
%
% Input
% -----
% Pack : Battery Pack Structure
%
% Output
% ------
% Result : Validation Report
%===========================================================

%% Input Validation

if nargin ~= 1
    error('Usage: validatePack(Pack)');
end

if ~isstruct(Pack)
    error('Input must be a battery pack structure.');
end

%% Initialize Report

Result.IsValid = true;
Result.Errors = {};
Result.Warnings = {};

fprintf("\n");
fprintf("=========================================\n");
fprintf(" BATTERY PACK VALIDATION\n");
fprintf("=========================================\n");

%% Voltage

if Pack.MaximumVoltage > 800

    fprintf("[FAIL] Maximum Voltage\n");

    Result.IsValid = false;
    Result.Errors{end+1} = ...
        "Maximum voltage exceeds 800 V.";

else

    fprintf("[PASS] Maximum Voltage\n");

end

%% Capacity

if Pack.Capacity <= 0

    fprintf("[FAIL] Capacity\n");

    Result.IsValid = false;
    Result.Errors{end+1} = ...
        "Invalid battery capacity.";

else

    fprintf("[PASS] Capacity\n");

end

%% Current

if Pack.MaxDischargeCurrent <= 0

    fprintf("[FAIL] Maximum Current\n");

    Result.IsValid = false;
    Result.Errors{end+1} = ...
        "Invalid maximum discharge current.";

else

    fprintf("[PASS] Maximum Current\n");

end

%% Cell Count

if Pack.TotalCells > 5000

    fprintf("[WARN] Cell Count\n");

    Result.Warnings{end+1} = ...
        "Battery pack contains more than 5000 cells.";

else

    fprintf("[PASS] Cell Count\n");

end

%% Mass

if Pack.Mass > 600

    fprintf("[WARN] Pack Mass\n");

    Result.Warnings{end+1} = ...
        "Battery pack is very heavy.";

else

    fprintf("[PASS] Pack Mass\n");

end

%% Energy

if Pack.Energy_Wh <= 0

    fprintf("[FAIL] Energy\n");

    Result.IsValid = false;
    Result.Errors{end+1} = ...
        "Invalid battery energy.";

else

    fprintf("[PASS] Energy\n");

end

%% Resistance

if Pack.R0 <= 0 || Pack.R1 <= 0

    fprintf("[FAIL] ECM Parameters\n");

    Result.IsValid = false;
    Result.Errors{end+1} = ...
        "Invalid ECM parameters.";

else

    fprintf("[PASS] ECM Parameters\n");

end

%% Temperature

if Pack.MaxCellTemperature <= Pack.MinCellTemperature

    fprintf("[FAIL] Temperature Limits\n");

    Result.IsValid = false;
    Result.Errors{end+1} = ...
        "Invalid temperature limits.";

else

    fprintf("[PASS] Temperature Limits\n");

end

%% SOC

if Pack.InitialSOC < 0 || Pack.InitialSOC > 1

    fprintf("[FAIL] Initial SOC\n");

    Result.IsValid = false;
    Result.Errors{end+1} = ...
        "Initial SOC must be between 0 and 1.";

else

    fprintf("[PASS] Initial SOC\n");

end

%% SOH

if Pack.InitialSOH <= 0 || Pack.InitialSOH > 1

    fprintf("[FAIL] Initial SOH\n");

    Result.IsValid = false;
    Result.Errors{end+1} = ...
        "Initial SOH must be between 0 and 1.";

else

    fprintf("[PASS] Initial SOH\n");

end

%% Summary

fprintf("-----------------------------------------\n");

if Result.IsValid

    fprintf("VALIDATION STATUS : PASSED\n");

else

    fprintf("VALIDATION STATUS : FAILED\n");

end

fprintf("Errors   : %d\n",numel(Result.Errors));
fprintf("Warnings : %d\n",numel(Result.Warnings));

fprintf("=========================================\n");

end