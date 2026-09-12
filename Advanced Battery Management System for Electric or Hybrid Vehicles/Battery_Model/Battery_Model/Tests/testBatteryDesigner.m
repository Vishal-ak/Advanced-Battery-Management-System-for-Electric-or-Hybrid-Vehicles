clc
clear
close all

%% Advanced Battery Design Platform
% Perform an integrated battery-pack design using the specified
% voltage and capacity requirements.
%
% The BatteryDesigner function automatically:
%   1. Determines a suitable series-parallel cell configuration
%   2. Creates the battery pack
%   3. Optimizes the pack design
%   4. Calculates electrical, energy, mass, and cost parameters
%   5. Validates the designed battery pack
%   6. Compares the custom pack with available commercial packs
%   7. Provides a final battery-pack recommendation

Report = BatteryDesigner(48,20);