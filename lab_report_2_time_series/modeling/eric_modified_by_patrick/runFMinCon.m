function [ res ] = runFMinCon( params0,initial_conditions,EGF_conc,inhib,...
                    time_course,te,tp,fract,tf,conc,conc2)

upperBound = 3*params0;
lowerBound = zeros(size(params0));

opts=optimset('Display','iter','MaxFunEvals',5e2,'MaxIter',5e2,'TolFun',0.1, ...
    'TypicalX',params0);

model = @(p)  func3_fmin(p,initial_conditions,EGF_conc,inhib, ...
               time_course,te,tp,fract,tf,conc,conc2);
%res=fmincon(@(p) model(p),params0,[],[],[],[],lowerBound,upperBound,[],opts);

res=fminsearch(@(p) model(p),params0,opts);

             

end

