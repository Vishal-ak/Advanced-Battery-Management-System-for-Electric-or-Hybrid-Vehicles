function I = driveCycleCurrent(t)

% ==========================================================
% Simple EV Drive Cycle Current Profile
%
% + Current = Discharge
% - Current = Regenerative Braking
% ==========================================================

I=zeros(size(t));

for k=1:length(t)

    time=t(k);

    if time<40

        I(k)=8;

    elseif time<70

        I(k)=25;

    elseif time<100

        I(k)=12;

    elseif time<120

        I(k)=-8;

    elseif time<170

        I(k)=30;

    elseif time<220

        I(k)=15;

    elseif time<250

        I(k)=0;

    else

        I(k)=20;

    end

end

end
