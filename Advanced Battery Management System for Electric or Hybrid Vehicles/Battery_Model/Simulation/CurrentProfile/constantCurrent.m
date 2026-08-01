function I = constantCurrent(t, current)

% ==========================================================
% Constant Current Profile
%
% Input:
%   t       -> time vector
%   current -> discharge current (A)
%
% Output:
%   I -> current profile
% ==========================================================

I = current * ones(size(t));

end