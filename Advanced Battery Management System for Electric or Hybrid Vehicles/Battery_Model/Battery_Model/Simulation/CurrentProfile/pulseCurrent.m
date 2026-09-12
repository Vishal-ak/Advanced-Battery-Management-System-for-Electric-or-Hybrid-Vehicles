function I = pulseCurrent(t)

% ==========================================================
% Pulse Current Profile
%
% Every 40 seconds:
%   20 s -> 10 A
%   20 s -> 0 A
% ==========================================================

I=zeros(size(t));

period=40;

for k=1:length(t)

    if mod(t(k),period)<20

        I(k)=10;

    else

        I(k)=0;

    end

end

end