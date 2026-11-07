function Result = validatePack(Pack,Requirements)
%VALIDATEPACK Check pack consistency and optional application requirements.
% Supported Requirements fields:
% MaxPackVoltage_V, MaxPackMass_kg, MaxCellCount, MinCapacity_Ah,
% MinDischargeCurrent_A, MinTemperature_C, MaxTemperature_C.
% Unspecified application limits are not guessed; they are warnings.

if nargin < 1 || nargin > 2 || ~isstruct(Pack) || ~isscalar(Pack)
    error('BMS:InvalidPack','Pack must be a scalar structure.');
end
if nargin < 2 || isempty(Requirements), Requirements = struct(); end
if ~isstruct(Requirements) || ~isscalar(Requirements)
    error('BMS:InvalidRequirements','Requirements must be a scalar structure.');
end
Result.IsValid = true;
Result.Errors = {};
Result.Warnings = {};
Result.Checks = struct();

required = {'Ns','Np','TotalCells','NominalVoltage','MaximumVoltage', ...
    'CutoffVoltage','Capacity','MaxDischargeCurrent','Energy_Wh', ...
    'R0','R1','C1','Mass','InitialSOC','InitialSOH', ...
    'MinCellTemperature','MaxCellTemperature','MinimumSOC','MaximumSOC'};
for k = 1:numel(required)
    f = required{k};
    if ~isfield(Pack,f) || ~isnumeric(Pack.(f)) || ...
            ~isscalar(Pack.(f)) || ~isfinite(Pack.(f))
        Result.Errors{end+1} = ['Missing or invalid Pack.' f];
    end
end
if ~isempty(Result.Errors)
    Result.IsValid = false;
    showSummary();
    return;
end

check('Series/parallel counts',Pack.Ns >= 1 && Pack.Np >= 1 && ...
    fix(Pack.Ns)==Pack.Ns && fix(Pack.Np)==Pack.Np, ...
    'Ns and Np must be positive integers.');
check('Cell count consistency',Pack.TotalCells == Pack.Ns*Pack.Np, ...
    'TotalCells must equal Ns multiplied by Np.');
check('Voltage ordering',Pack.CutoffVoltage > 0 && ...
    Pack.CutoffVoltage < Pack.NominalVoltage && ...
    Pack.NominalVoltage < Pack.MaximumVoltage, ...
    'Expected 0 < cutoff < nominal < maximum pack voltage.');
check('Capacity',Pack.Capacity > 0,'Pack capacity must be positive.');
check('Maximum discharge current',Pack.MaxDischargeCurrent > 0, ...
    'Maximum discharge current must be positive.');
check('Energy consistency',Pack.Energy_Wh > 0 && ...
    abs(Pack.Energy_Wh-Pack.NominalVoltage*Pack.Capacity) <= ...
    max(1e-8,1e-6*Pack.Energy_Wh), ...
    'Energy must equal nominal voltage multiplied by capacity.');
check('ECM parameters',Pack.R0 > 0 && Pack.R1 > 0 && Pack.C1 > 0, ...
    'R0, R1 and C1 must be positive.');
check('Mass',Pack.Mass > 0,'Pack mass must be positive.');
check('SOC limits',Pack.MinimumSOC >= 0 && Pack.MaximumSOC <= 1 && ...
    Pack.MinimumSOC <= Pack.InitialSOC && Pack.InitialSOC <= Pack.MaximumSOC, ...
    'SOC limits and initial SOC must be ordered within [0,1].');
check('SOH',Pack.InitialSOH > 0 && Pack.InitialSOH <= 1, ...
    'Initial SOH must be in (0,1].');
check('Temperature limits',Pack.MaxCellTemperature > Pack.MinCellTemperature, ...
    'Maximum cell temperature must exceed minimum.');

applyLimit('MaxPackVoltage_V',Pack.MaximumVoltage,@le, ...
    'Maximum pack voltage exceeds application limit.');
applyLimit('MaxPackMass_kg',Pack.Mass,@le, ...
    'Estimated pack mass exceeds application limit.');
applyLimit('MaxCellCount',Pack.TotalCells,@le, ...
    'Cell count exceeds application limit.');
applyLimit('MinCapacity_Ah',Pack.Capacity,@ge, ...
    'Pack capacity is below application requirement.');
applyLimit('MinDischargeCurrent_A',Pack.MaxDischargeCurrent,@ge, ...
    'Discharge current capability is below application requirement.');
applyLimit('MinTemperature_C',Pack.MinCellTemperature,@ge, ...
    'Minimum operating temperature is above application requirement.');
applyLimit('MaxTemperature_C',Pack.MaxCellTemperature,@le, ...
    'Maximum operating temperature exceeds application limit.');

Result.IsValid = isempty(Result.Errors);
showSummary();

    function check(name,condition,message)
        Result.Checks.(matlab.lang.makeValidName(name)) = logical(condition);
        if condition
            fprintf('[PASS] %s\n',name);
        else
            fprintf('[FAIL] %s\n',name);
            Result.Errors{end+1} = message;
        end
    end
    function applyLimit(field,value,operator,message)
        if isfield(Requirements,field)
            limit = Requirements.(field);
            if ~isnumeric(limit) || ~isscalar(limit) || ~isfinite(limit)
                error('BMS:InvalidRequirementValue', ...
                    'Requirements.%s must be a finite numeric scalar.',field);
            end
            check(['Requirement_' field],operator(value,limit),message);
        else
            Result.Warnings{end+1} = ['Application limit not supplied: ' field];
        end
    end
    function showSummary()
        fprintf('\n=========================================\n');
        fprintf(' BATTERY PACK VALIDATION\n');
        if Result.IsValid, fprintf('VALIDATION STATUS : PASSED\n');
        else, fprintf('VALIDATION STATUS : FAILED\n'); end
        fprintf('Errors   : %d\nWarnings : %d\n', ...
            numel(Result.Errors),numel(Result.Warnings));
        fprintf('=========================================\n');
    end
end