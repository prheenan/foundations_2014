function dx=ode_fun_simple(x,s,w,e)
%ode_res is the change in x according to rates w and stoichiometry s

    %Signal Propagation
    ode_res(1)=w(1)*x(1)^e(1)*x(2)^e(25);%EGFl to EGFR
    ode_res(2)=w(2)*x(3)^e(2);%EGFR to Ras
    ode_res(3)=w(3)*x(4)^e(3);%Ras to Raf - binding interaction
    ode_res(4)=w(4)*x(5)^e(4);%Raf to MEK
    ode_res(5)=w(5)*x(6)^e(5);%MEK to ERK
    ode_res(6)=w(6)*x(7)^e(6);%ERK to TACE
    ode_res(7)=w(7)*x(8)^e(7);%TACE to EGFl where's my TGFa
    ode_res(8)=w(8)*x(3)^e(8);%EGFR to Src
    ode_res(9)=w(9)*x(4)^e(9);%Ras to p38
    
    %Signal Degradation
    ode_res(10)=w(10)*x(3)^e(10)+w(22)*x(3)^e(22)/w(26);%EGFR decay
    ode_res(11)=w(11)*x(4)^e(11);%Ras decay
    ode_res(12)=w(12)*x(5)^e(12);%Raf decay
    ode_res(13)=w(13)*x(6)^e(13);%MEK decay
    ode_res(14)=w(14)*x(7)^e(14);%ERK decay
    ode_res(15)=w(15)*x(8)^e(15);%TACE decay
    ode_res(16)=w(16)*x(1)^e(16);%EGFl loss
    ode_res(17)=w(17)*x(9)^e(17);%Src decay
    ode_res(18)=w(18)*x(10)^e(18);%p38 decay
    
    %Non-canon TACE Activation
    ode_res(19)=w(19)*x(9)^e(19);%Src to TACE
    ode_res(20)=w(20)*x(10)^e(20);%p38 to TACE
    
    ode_res(21)=w(21);%EGFR presentation
    ode_res(22)=w(22)*x(2)^e(22);%EGFR endocytosis - now also mechanical
    ode_res(23)=w(23)*x(5)^e(23);%ERK to Raf negative feedback
    %Stochastic Activation
    ode_res(24)=w(24)*rand(1);%random activation of TACE
    ode_res(25)=w(25)*rand(1);%stochastic raf activation
    %NOTE:e(25) is for the first reaction now
    
    ode_res(26)=w(26);%Mechanical TACE activation

    for i=1:26
        ds(i,:)=ode_res(i)*s(i,:);
    end
    
    dx=sum(ds);
end