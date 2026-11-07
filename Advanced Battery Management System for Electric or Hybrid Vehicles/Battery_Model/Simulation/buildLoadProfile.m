function [I,Details] = buildLoadProfile(Config)
% +I is discharge; -I is charging/regeneration.
t=Config.Time; type=lower(char(Config.LoadType));
switch type
 case {'constant-current','constant'}, I=constantCurrent(t,Config.Load.Current);
 case 'step', I=zeros(size(t)); I(t<100)=5; I(t>=100&t<200)=15; I(t>=200)=8;
 case 'pulse', I=pulseCurrent(t);
 case 'drive-cycle', I=driveCycleCurrent(t);
 case 'custom-current'
  x=Config.Load.Current;
  if numel(x)~=numel(t)||any(~isfinite(x(:))), error('BMS:InvalidCustomCurrent','Current must match Time and be finite.'); end
  I=x(:);
 case 'power'
  if ~isscalar(Config.Load.Power)||~isfinite(Config.Load.Power), error('BMS:InvalidPower','Power must be finite scalar watts.'); end
  I=(Config.Load.Power/max(Config.Pack.NominalVoltage,eps))*ones(size(t));
 otherwise, error('BMS:UnknownLoadType','Unsupported load type: %s',type);
end
if numel(I)~=numel(t)||any(~isfinite(I(:))), error('BMS:InvalidLoadProfile','Load must be finite and match time.'); end
Details.Type=string(type); Details.PeakDischargeCurrent=max([0;I(:)]);
Details.PeakChargeCurrent=min([0;I(:)]); Details.SignConvention="+ discharge, - charge";
end