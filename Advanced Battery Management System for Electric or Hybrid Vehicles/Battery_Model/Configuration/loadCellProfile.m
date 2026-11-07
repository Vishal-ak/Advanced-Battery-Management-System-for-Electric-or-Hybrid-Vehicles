function Battery = loadCellProfile(cellID)
% Load one selected profile; each profile exposes Scripts/initCellProfile.m.
if nargin~=1 || ~(ischar(cellID)||(isstring(cellID)&&isscalar(cellID)))
 error('BMS:InvalidCellID','Provide one cell-library ID.');
end
cellID=char(cellID); p=listCellProfiles(); idx=find(strcmp({p.ID},cellID),1);
if isempty(idx), error('BMS:UnknownCell','Cell profile "%s" is unavailable.',cellID); end
if ~p(idx).Loadable, error('BMS:CellProfileLoaderMissing','Profile %s has no standard loader.',cellID); end
if strcmp(cellID,'Panasonic_NCR18650B')
 Battery=initBattery();
else
 loaderFolder=fullfile(p(idx).Folder,'Scripts');
 addpath(loaderFolder,'-begin');
 clear initCellProfile;
 Battery=initCellProfile();
 clear initCellProfile;
end
if ~isstruct(Battery)||~isfield(Battery,'OCV_Table')||~isfield(Battery,'SOC_Table')
 error('BMS:InvalidCellProfile','Loader must return Battery with SOC_Table and OCV_Table.');
end
Battery.CellLibraryID=string(cellID);
end
