function SOC_new = coulombCounting(SOC_old, current, dt, capacity_Ah)

Q = capacity_Ah * 3600;   % Convert Ah to Coulombs

SOC_new = SOC_old - (current * dt) / Q;

% Limit SOC between 0 and 1
SOC_new = max(0, min(1, SOC_new));

end