function Profiles = listCellProfiles()
% Discover cell folders containing Data/OCV_SOC.csv.
root=fileparts(fileparts(mfilename('fullpath'))); library=fullfile(root,'Cell_Library');
d=dir(library); Profiles=struct('ID',{},'Folder',{},'HasOCV',{},'Loadable',{});
for k=1:numel(d)
 if ~d(k).isdir || startsWith(d(k).name,'.'), continue; end
 folder=fullfile(library,d(k).name); ocv=fullfile(folder,'Data','OCV_SOC.csv');
 loader=fullfile(folder,'Scripts','initCellProfile.m');
 if isfile(ocv)
  p.ID=d(k).name; p.Folder=folder; p.HasOCV=true;
  p.Loadable=isfile(loader)||strcmp(d(k).name,'Panasonic_NCR18650B');
  Profiles(end+1)=p; %#ok<AGROW>
 end
end
if isempty(Profiles), error('BMS:NoCellProfiles','No cell profile with OCV-SOC data found.'); end
end