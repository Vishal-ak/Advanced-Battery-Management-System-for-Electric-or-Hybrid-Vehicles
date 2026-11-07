function [BleedActive,BleedCurrent,Imbalance_mV] = passiveCellBalancing(Voltages,R_bleed,Threshold,EnableBalancing)
%PASSIVECELLBALANCING Idealized switched-shunt passive balancing logic.
% Bleed current is V/R for each enabled shunt. Parasitic losses, cell
% impedance, thermal rise and balancing timing are not modeled.
if nargin < 4 || isempty(EnableBalancing), EnableBalancing = true; end
if nargin < 3 || isempty(Threshold), Threshold = 0.015; end
if nargin < 2 || isempty(R_bleed), R_bleed = 39.0; end
if ~isnumeric(Voltages) || isempty(Voltages) || ~isvector(Voltages) || any(~isfinite(Voltages)) || any(Voltages <= 0)
    error('BMS:InvalidCellVoltages','Voltages must be a positive finite vector.');
end
if ~isscalar(R_bleed) || ~isfinite(R_bleed) || R_bleed <= 0 || ~isscalar(Threshold) || ~isfinite(Threshold) || Threshold < 0
    error('BMS:InvalidBalancingParameter','R_bleed must be positive and Threshold nonnegative.');
end
if ~islogical(EnableBalancing) || ~isscalar(EnableBalancing)
    error('BMS:InvalidEnableFlag','EnableBalancing must be a logical scalar.');
end
vmin = min(Voltages);
Imbalance_mV = (max(Voltages)-vmin)*1000;
BleedActive = false(size(Voltages));
BleedCurrent = zeros(size(Voltages));
% Simplified top-balance enable condition; real control requires validated
% chemistry-specific voltage, SOC, temperature and charge-state limits.
if EnableBalancing && all(Voltages >= 3.60)
    BleedActive = (Voltages-vmin) >= Threshold;
    BleedCurrent(BleedActive) = Voltages(BleedActive)./R_bleed;
end
end