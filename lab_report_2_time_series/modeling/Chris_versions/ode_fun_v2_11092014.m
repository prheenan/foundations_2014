function dx=ode_fun_simple(x,s,k,e)
%ode_res is the change in x according to rates w and stoichiometry s

    %Signal Propagation
        %each ode_res value is an amount of change;
        %that amount of change is later applied to each molecule based on
        %stoichiometry 
    ode_res(1)=k(1) * ( x(1)*x(2) )^e(1); %actEGF bind to EGFR
    ode_res(2)=k(2)*x(3)^e(2); %EGF_EGFR dissociation
    ode_res(3)=k(3) * ( x(3)*x(4) )^e(3); %SOS activation by actEGF_EGFR
    ode_res(4)=k(4)*x(5)^e(4); %SOS deactivation
    ode_res(5)=k(5) * ( x(5)*x(6) )^e(5); %RAS activation by actSOS
    ode_res(6)=k(6)*x(7)^e(6); %RAS  deactivation
    ode_res(7)=k(7) * ( x(7)*x(8) )^e(7); %RAF activation by actRAS
    ode_res(8)=k(8)*x(9)^e(8); %RAF deactivation
    ode_res(9)=k(9) * ( x(9)*x(10) )^e(9); %MEK activation by actRAF
    ode_res(10)=k(10)*x(11)^e(10); %MEK  deactivation
    ode_res(11)=k(11) * ( x(11)*x(12) ) ^e(11); %ERK activation by actMEK
    ode_res(12)=k(12)*x(13)^e(12); %ERK deactivation
    ode_res(13)=k(13) * ( x(4)*x(13) ) ^e(13); %ERK-SOS neg feedback
    ode_res(14)=k(14)*x(14)^e(14); %ERK-SOS dissociation
    ode_res(15)=k(15) * ( x(8)*x(13) ) ^e(15); %ERK-RAF neg feedback
    ode_res(16)=k(16)*x(15)^e(16); %ERK-RAF dissociation
    ode_res(17)=( k(17) * ( x(16)*x(17) ) ^e(17) )*0; %TACE cleaves EGF (not using this currently)
    ode_res(18)=k(18) * ( x(16)*x(18) ) ^e(18); %TACE cleaves TGFa
    ode_res(19)=k(19) * ( x(2)*x(19) ) ^e(19); %actTGFa to EGFR
    ode_res(20)=k(20)*x(20)^e(20); %actTGFa_EGFR dissociate
    ode_res(21)=k(21) * ( x(4)*x(20) )^e(21); %SOS activation by actTGFa_EGFR
    ode_res(22)=k(22) * ( x(13)*x(21) )^e(22); %TACE activation by actERK
    ode_res(23)=k(23) * ( x(1)*x(22) )^e(23); %inhibition of target (changes)
    ode_res(24)=(k(24)*(x(22)^e(24)))*0; %increasing inhibitor concentration linearly (not using this currently)
    ode_res(25)=k(25)*x(16)^e(25); %TACE deactivation
    

    for i=1:25 %update this range with number of changes (not number of molecules)
        ds(i,:)=ode_res(i)*s(i,:);
    end
    
    dx=sum(ds);
end