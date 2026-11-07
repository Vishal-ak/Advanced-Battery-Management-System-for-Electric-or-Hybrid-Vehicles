function Results = runConfigurableSimulation(Config)
% Pack-equivalent 1RC ECM, coulomb counting and lumped thermal simulation.
[I,info]=buildLoadProfile(Config); t=Config.Time(:); N=numel(t);
B=Config.Battery; P=Config.Pack; dt=diff(t);
SOC=zeros(N,1); V=zeros(N,1); OCV=zeros(N,1); Temp=zeros(N,1); Vrc=zeros(N,1);
Heat=zeros(N,1); over=false(N,1); under=false(N,1);
SOC(1)=B.InitialSOC; Temp(1)=B.InitialTemperature;
for k=1:N
 if k>1
  SOC(k)=coulombCounting(SOC(k-1),I(k-1),dt(k-1),P.Capacity);
  Heat(k-1)=calcHeatGeneration(I(k-1),P);
  Temp(k)=updateTemperature(Temp(k-1),Heat(k-1),Config.AmbientTemperature,dt(k-1),P);
  [V(k),Vrc(k),OCV(k),s]=batteryECM(SOC(k),I(k),Vrc(k-1),dt(k-1),P);
 else
  [V(k),Vrc(k),OCV(k),s]=batteryECM(SOC(k),I(k),0,Config.TimeStep,P);
 end
 over(k)=s.OverVoltage; under(k)=s.UnderVoltage;
end
Heat(N)=calcHeatGeneration(I(N),P);
Results.Time=t; Results.Current=I(:); Results.SOC=SOC; Results.TerminalVoltage=V;
Results.OCV=OCV; Results.Temperature=Temp; Results.HeatGeneration=Heat;
Results.OverVoltage=over; Results.UnderVoltage=under; Results.VoltageViolation=over|under;
Results.LoadInfo=info; Results.Pack=P;
Results.ModelScope="Pack-equivalent 1RC; assumes identical cells and equal current sharing";
end