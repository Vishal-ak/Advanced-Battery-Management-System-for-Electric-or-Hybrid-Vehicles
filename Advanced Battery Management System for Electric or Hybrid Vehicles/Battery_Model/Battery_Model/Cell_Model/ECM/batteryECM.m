function [Vt,Vrc_new,OCV] = batteryECM(...
SOC,current,Vrc_old,dt,Battery)
%===========================================================
% FIRST ORDER ECM
%
% Inputs
%
% SOC
% Current
% Previous RC Voltage
% dt
% battery structure
%
% Outputs
%
% Terminal Voltage
% Updated RC Voltage
% OCV
%===========================================================

%% Load Lookup Table

SOC_Table = Battery.SOC_Table;
OCV_Table = Battery.OCV_Table;

%% Lookup OCV

OCV = interp1(...
    SOC_Table,...
    OCV_Table,...
    SOC,...
    'linear',...
    'extrap');

%% Update RC Voltage

Vrc_new = updateRCVoltage(...
    Vrc_old,...
    current,...
    dt,...
    Battery.R1,...
    Battery.C1);

%% Terminal Voltage

Vt = terminalVoltage(...
    OCV,...
    current,...
    Battery.R0,...
    Vrc_new);

%% Voltage Limits

Vt = min(Vt, Battery.MaximumVoltage);

Vt = max(Vt, Battery.CutoffVoltage);

end