function outputFiles = saveBMSFigure(fig, projectRoot, category, baseName)
%SAVEBMSFIGURE Save a BMS result figure as a publication-quality PNG and FIG.
%
% outputFiles = saveBMSFigure(fig, projectRoot, category, baseName)
%   fig         - Valid MATLAB figure handle.
%   projectRoot - Absolute path to the canonical Battery_Model directory.
%   category    - Relative folder below Results, e.g. 'Cell_Model/ECM/1RC'.
%   baseName    - File stem without extension, e.g. 'ECM_1RC_Terminal_Voltage'.
%
% PNG files are exported at 300 dpi. FIG files remain editable in MATLAB.
% Existing files with the same names are overwritten.

if nargin ~= 4
    error('BMS:InvalidSaveArguments', ...
        'Usage: saveBMSFigure(fig, projectRoot, category, baseName)');
end
if ~isgraphics(fig, 'figure')
    error('BMS:InvalidFigureHandle', 'fig must be a valid MATLAB figure handle.');
end
if ~(ischar(projectRoot) || (isstring(projectRoot) && isscalar(projectRoot))) || ...
        ~isfolder(projectRoot)
    error('BMS:InvalidProjectRoot', 'projectRoot must be an existing project folder.');
end
if ~(ischar(category) || (isstring(category) && isscalar(category))) || ...
        isempty(char(category)) || contains(char(category), '..') || ...
        startsWith(char(category), filesep)
    error('BMS:InvalidCategory', 'category must be a relative Results subfolder.');
end
if ~(ischar(baseName) || (isstring(baseName) && isscalar(baseName))) || ...
        isempty(char(baseName)) || contains(char(baseName), filesep)
    error('BMS:InvalidBaseName', 'baseName must be a non-empty filename without path separators.');
end

resultsFolder = fullfile(projectRoot, 'Results', char(category));
if ~isfolder(resultsFolder)
    [ok, message] = mkdir(resultsFolder);
    if ~ok
        error('BMS:ResultsFolderCreationFailed', ...
            'Could not create Results folder: %s', message);
    end
end

pngFile = fullfile(resultsFolder, [char(baseName) '.png']);
figFile = fullfile(resultsFolder, [char(baseName) '.fig']);

exportgraphics(fig, pngFile, 'Resolution', 300);
savefig(fig, figFile);

outputFiles = struct('png', pngFile, 'fig', figFile);
fprintf('Saved PNG: %s\n', pngFile);
fprintf('Saved FIG: %s\n', figFile);
end
