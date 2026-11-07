function Battery = initCell_LG_INR18650_MJ1()
% Datasheet-backed LG MJ1 cell profile. ECM/thermal placeholders are provisional.
root=fileparts(fileparts(mfilename('fullpath'))); dataFolder=fullfile(root,'Data');
Battery.dataFolder=dataFolder; Battery.CellModel="LG INR18650 MJ1";
Battery.Manufacturer="LG Chem"; Battery.Chemistry="Lithium-Ion (NMC/SiOx)";
Battery.CellType="18650 Cylindrical";
Battery.NominalVoltage=3.635; Battery.MaximumVoltage=4.20; Battery.CutoffVoltage=2.50;
Battery.MinimumCapacity=3.35; Battery.TypicalCapacity=3.50; Battery.DesignCapacity=3.35;
Battery.InternalResistance=0.040; Battery.StandardChargeCurrent=1.675; Battery.MaxChargeCurrent=3.35;
Battery.MaxDischargeCurrent=10.0; Battery.CapacityCoulomb=Battery.DesignCapacity*3600;
Battery.Mass=0.049; Battery.Diameter=18.65; Battery.Height=65.3;
Battery.CellEnergy_Wh=Battery.NominalVoltage*Battery.DesignCapacity;
Battery.GravimetricEnergyDensity=Battery.CellEnergy_Wh/Battery.Mass;
Battery.VolumetricEnergyDensity=Battery.CellEnergy_Wh/(pi*(Battery.Diameter/2)^2*Battery.Height/1e6);
Battery.Volume_mm3=pi*(Battery.Diameter/2)^2*Battery.Height; Battery.Volume_L=Battery.Volume_mm3/1e6;
Battery.SpecificHeat=900; Battery.ThermalResistance=5;
Battery.InitialTemperature=25;
Battery.R0=0.040; Battery.R1=0.012; Battery.C1=2400;
Battery.ECMParameterStatus="R0 uses datasheet maximum 1kHz AC impedance; R1/C1 are provisional placeholders, not HPPC-identified.";
Battery.ThermalParameterStatus="Specific heat and thermal resistance are provisional placeholders; characterize experimentally.";
Battery.InitialSOC=1; Battery.MinimumSOC=0.05; Battery.MaximumSOC=1; Battery.InitialSOH=1;
Battery.MaxCellVoltage=4.20; Battery.MinCellVoltage=2.50;
Battery.MaxCellTemperature=60; Battery.MinCellTemperature=-20;
Battery.MinChargeTemperature=0; Battery.MaxChargeTemperature=45;
Battery.MinDischargeTemperature=-20; Battery.MaxDischargeTemperature=60;
Battery.OCV=readtable(fullfile(dataFolder,'OCV_SOC.csv'));
Battery.SOC_Table=Battery.OCV.SOC; Battery.OCV_Table=Battery.OCV.OCV;
Battery.OCVDataStatus="Illustrative interpolated SOC-voltage placeholder; not sourced from a verified full-cell equilibrium OCV dataset. Replace before quantitative simulation.";
Battery.CellCost=NaN;
Battery.BMSWeight=0.25; Battery.EnclosureWeight=0.35; Battery.BusbarWeight=0.15; Battery.WiringWeight=0.10;
end
