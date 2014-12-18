function [time, y_vals]=func2_TimeCourse(params,initial_conditions,...
    EGF_conc,inhib,time_course,te,tp,conc,conc2)

EGF_cell=0;

y=zeros(numel(time_course)-1,length(initial_conditions));
y(1,:)=initial_conditions;
time=[];y_all=[];

for t=1:numel(time_course)-1
    if time_course(t)==tp
        %y(t,:)=y(t,:)+pert;
    end
    %time of egf addition
    if time_course(t)>te
        EGF_cell=EGF_conc;
    end
    %time of perturbation
    if time_course(t)>tp
        %parameters change upon inhibitor addition
        conc2(inhib(1))=conc(inhib(1),inhib(2));
    end
    
    options=odeset('NonNegative',1:25);
    [time_now, y_now]=ode15s(@(t,y)func_ODEs(t,y,conc,conc2,params),t:t+1,y(t,:),options);
    time=[time;time_now];
    y_all=[y_all;y_now];
    
    y_cor=y_all;
    %y_cor(y_cor<0)=0;
    if y_cor(end,17)<EGF_cell,y_cor(end,17)=EGF_cell;end
    
    y(t+1,:)=y_cor(end,:);
end

y_vals=y;

end


