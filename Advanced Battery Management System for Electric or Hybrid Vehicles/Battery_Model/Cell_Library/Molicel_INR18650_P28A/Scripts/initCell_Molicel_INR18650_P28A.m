function Battery = initCell_Molicel_INR18650_P28A()
% Datasheet-backed Molicel P28A profile. ECM/thermal placeholders are provisional.
root=fileparts(fileparts(mfilename('fullpath'))); dataFolder=fullfile(root,'Data');
Battery.dataFolder=dataFolder; Battery.CellModel="Molicel INR-18650-P28A";
Battery.Manufacturer="E-One Moli Energy"; Battery.Chemistry="Lithium-Ion (NMC)";
Battery.CellType="18650 Cylindrical";
Battery.NominalVoltage=3.60; Battery.MaximumVoltage=4.20; Battery.CutoffVoltage=2.50;
Battery.MinimumCapacity=2.70; Battery.TypicalCapacity=2.80; Battery.DesignCapacity=2.70;
Battery.InternalResistance=0.020; Battery.StandardChargeCurrent=2.80; Battery.MaxChargeCurrent=8.40;
Battery.MaxDischargeCurrent=35.0; Battery.CapacityCoulomb=Battery.DesignCapacity*3600;
Battery.Mass=0.046; Battery.Diameter=18.6; Battery.Height=65.2;
Battery.CellEnergy_Wh=Battery.NominalVoltage*Battery.DesignCapacity;
Battery.GravimetricEnergyDensity=Battery.CellEnergy_Wh/Battery.Mass;
Battery.VolumetricEnergyDensity=Battery.CellEnergy_Wh/(pi*(Battery.Diameter/2)^2*Battery.Height/1e6);
Battery.Volume_mm3=pi*(Battery.Diameter/2)^2*Battery.Height; Battery.Volume_L=Battery.Volume_mm3/1e6;
Battery.SpecificHeat=900; Battery.ThermalResistance=5; Battery.InitialTemperature=25;
Battery.R0=0.020; Battery.R1=0.008; Battery.C1=1800;
Battery.ECMParameterStatus="R0 uses datasheet maximum 1kHz AC impedance; R1/C1 are provisional placeholders, not HPPC-identified.";
Battery.ThermalParameterStatus="Specific heat and thermal resistance are provisional placeholders; characterize experimentally.";
Battery.InitialSOC=1; Battery.MinimumSOC=0.05; Battery.MaximumSOC=1; Battery.InitialSOH=1;
Battery.MaxCellVoltage=4.20; Battery.MinCellVoltage=2.50;
Battery.MaxCellTemperature=60; Battery.MinCellTemperature=-40;
Battery.OCV=readtable(fullfile(dataFolder,'OCV_SOC.csv'));
Battery.SOC_Table=Battery.OCV.SOC; Battery.OCV_Table=Battery.OCV.OCV;
Battery.OCVDataStatus="Pseudo-OCV lookup published for Molicel INR18650P28A at C/20; not a rested equilibrium OCV curve.";
Battery.CellCost=NaN;
Battery.BMSWeight=0.25; Battery.EnclosureWeight=0.35; Battery.BusbarWeight=0.15; Battery.WiringWeight=0.10;
end
