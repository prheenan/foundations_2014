function dx=ode_fun_simple(x,s,k,e)
%ode_res is the change in x according to rates w and stoichiometry s

    %Signal Propagation
        %each ode_res value is an amount of change;
        %that amount of change is later applied to each molecule based on
        %stoichiometry 
    ode_res(1)=k(1) * ( x(1)*x(2) )^e(1); %EGF bind to EGFR
    ode_res(2)=k(2)*x(3)^e(2); %EGF_EGFR dissociation
    ode_res(3)=k(3) * ( x(3)*x(4) )^e(3); %SOS activation by EGF_EGFR
    ode_res(4)=k(4)*x(5)^e(4); %SOS deactivation
    ode_res(5)=k(5) * ( x(5)*x(6) )^e(5); %RAS activation by actSOS
    ode_res(6)=k(6)*x(7)^e(6); %RAS  deactivation
    ode_res(7)=k(7) * ( x(7)*x(8) )^e(7); %RAF activation by actRAS
    ode_res(8)=k(8)*x(9)^e(8); %RAF deactivation
    ode_res(9)=k(9) * ( x(9)*x(10) )^e(9); %MEK activation by actRAF
    ode_res(10)=k(10)*x(11)^e(10); %MEK  deactivation
    ode_res(11)=k(11) * ( x(11)*x(12) ) ^e(11); %ERK activation by actMEK
    ode_res(12)=k(12)*x(13)^e(12); %ERK deactivation
    ode_res(13)=k(13) * ( x(4)*x(12) ) ^e(13); %ERK-SOS neg feedback
    ode_res(14)=k(14)*x(14)^e(14); %ERK-SOS dissociation
    ode_res(15)=k(15) * ( x(8)*x(12) ) ^e(15); %ERK-RAF neg feedback
    ode_res(16)=k(16)*x(15)^e(16); %ERK-RAF dissociation
    %ode_res(17)=k(17)*x(1)^e(17); %EGF degradation

    for i=1:16
        ds(i,:)=ode_res(i)*s(i,:);
    end
    
    dx=sum(ds);
end