function Config = createSimulationConfig(varargin)
% Name-value: CellID, PackMode, Ns, Np, TargetVoltage, TargetCapacity,
% LoadType, Time, Current, Power, AmbientTemperature, InitialSOC,
% InitialTemperature, TimeStep.
p=inputParser;
addParameter(p,'CellID','Panasonic_NCR18650B'); addParameter(p,'PackMode','manual');
addParameter(p,'Ns',13); addParameter(p,'Np',6);
addParameter(p,'TargetVoltage',48); addParameter(p,'TargetCapacity',20);
addParameter(p,'LoadType','constant-current'); addParameter(p,'Time',(0:1:3600)');
addParameter(p,'Current',10); addParameter(p,'Power',500);
addParameter(p,'AmbientTemperature',25); addParameter(p,'InitialSOC',1);
addParameter(p,'InitialTemperature',25); addParameter(p,'TimeStep',1);
parse(p,varargin{:}); a=p.Results; B=loadCellProfile(a.CellID);
if ~isscalar(a.TimeStep)||~isfinite(a.TimeStep)||a.TimeStep<=0, error('BMS:InvalidTimeStep','TimeStep must be positive.'); end
if ~isscalar(a.InitialSOC)||a.InitialSOC<0||a.InitialSOC>1, error('BMS:InvalidInitialSOC','InitialSOC must be in [0,1].'); end
if ~isvector(a.Time)||numel(a.Time)<2||any(~isfinite(a.Time(:)))||any(diff(a.Time(:))<=0), error('BMS:InvalidTime','Time must increase strictly.'); end
switch lower(char(a.PackMode))
 case 'manual', Pack=createBatteryPack(B,a.Ns,a.Np,false);
 case 'target'
  Ns=max(1,ceil(a.TargetVoltage/B.NominalVoltage)); Np=max(1,ceil(a.TargetCapacity/B.DesignCapacity));
  Pack=createBatteryPack(B,Ns,Np,false); Pack.DesignMethod="Target sizing; rounded upward";
 otherwise, error('BMS:InvalidPackMode','PackMode must be manual or target.');
end
B.InitialSOC=a.InitialSOC; B.InitialTemperature=a.InitialTemperature;
Config.CellID=string(a.CellID); Config.Battery=B; Config.Pack=Pack;
Config.PackMode=string(a.PackMode); Config.LoadType=string(a.LoadType);
Config.Time=a.Time(:); Config.TimeStep=a.TimeStep; Config.AmbientTemperature=a.AmbientTemperature;
Config.Load.Current=a.Current; Config.Load.Power=a.Power;
end