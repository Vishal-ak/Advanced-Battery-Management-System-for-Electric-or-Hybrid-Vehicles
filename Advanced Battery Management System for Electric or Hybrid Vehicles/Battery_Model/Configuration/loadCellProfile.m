function Battery = loadCellProfile(cellID)
% Load a cell profile by its Cell_Library folder name.
if nargin~=1 || ~(ischar(cellID)||(isstring(cellID)&&isscalar(cellID)))
 error('BMS:InvalidCellID','Provide one cell-library ID.');
end
cellID=char(cellID); p=listCellProfiles(); idx=find(strcmp({p.ID},cellID),1);
if isempty(idx), error('BMS:UnknownCell','Cell profile "%s" is unavailable.',cellID); end
if ~p(idx).Loadable, error('BMS:CellProfileLoaderMissing','Add Scripts/initCellProfile.m for %s.',cellID); end
if strcmp(cellID,'Panasonic_NCR18650B')
 Battery=initBattery();
else
 addpath(fullfile(p(idx).Folder,'Scripts')); Battery=initCellProfile();
end
if ~isstruct(Battery)||~isfield(Battery,'OCV_Table')||~isfield(Battery,'SOC_Table')
 error('BMS:InvalidCellProfile','Loader must return Battery with SOC_Table and OCV_Table.');
end
Battery.CellLibraryID=string(cellID);
end