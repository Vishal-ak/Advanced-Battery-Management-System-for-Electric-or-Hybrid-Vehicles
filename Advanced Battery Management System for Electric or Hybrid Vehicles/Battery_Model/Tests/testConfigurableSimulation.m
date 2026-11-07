function tests=testConfigurableSimulation
tests=functiontests(localfunctions);
end
function testCellDiscovery(testCase)
p=listCellProfiles(); verifyTrue(testCase,any(strcmp({p.ID},'Panasonic_NCR18650B')));
end
function testManualPack(testCase)
c=createSimulationConfig('Ns',10,'Np',4,'Time',(0:1:10)');
verifyEqual(testCase,c.Pack.Ns,10); verifyEqual(testCase,c.Pack.Np,4);
end
function testLoadTypes(testCase)
t=(0:1:20)'; modes={'constant-current','step','pulse','drive-cycle','power'};
for k=1:numel(modes)
 c=createSimulationConfig('Time',t,'LoadType',modes{k}); I=buildLoadProfile(c);
 verifySize(testCase,I,size(t)); verifyTrue(testCase,all(isfinite(I)));
end
end
function testCustomCurrent(testCase)
t=(0:1:10)'; i=2*t;
c=createSimulationConfig('Time',t,'LoadType','custom-current','Current',i);
I=buildLoadProfile(c); verifyEqual(testCase,I,i);
end
