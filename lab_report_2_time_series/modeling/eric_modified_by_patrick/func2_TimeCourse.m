function [time, y_vals]=func2_TimeCourse(params,initial_conditions, ... 
                                        EGF_conc,inhib,time_course,te,tp, ...
                                        conc,conc2)

concVector = 1:numel(initial_conditions);                                    
options=odeset('RelTol',1e-4,'InitialStep',0.5);                         
pModel = @(t,y) func_ODEs(t,y,inhib,params,EGF_conc,te,tp,conc,conc2);
[time, y_vals]=ode45(@(t,y) pModel(t,y), time_course,initial_conditions,options);
end




