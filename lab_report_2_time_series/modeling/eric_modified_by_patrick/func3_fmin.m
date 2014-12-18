function r2=func3_fmin(params,initial_conditions,EGF_conc,inhib,time_course,...
                        te,tp,fract,tf, conc,conc2)

time_course_eq = 0:1:300;
tp_eq=1;te_eq=1;
[~, y_equilib]=func2_TimeCourse(params,initial_conditions,0,[1,1],...
                                    time_course_eq,te_eq,tp_eq,conc,conc2);
initial_conditions2=y_equilib(end,:);


num_points=numel(tf);
num_exp=numel(EGF_conc);
% there are several indices for us to compare 'aERK' to 'ERK'
targetIndices = tf-min(time_course)+1;

r = zeros(num_exp,num_points);

for exp=1:num_exp

    [~, y_vals]=func2_TimeCourse(params,initial_conditions2,EGF_conc(exp),...
                                    inhib,time_course,te,tp,conc,conc2);

    aERK_t=y_vals(targetIndices,11);
    ERK_t=y_vals(targetIndices,12);
    
    mod_fract=aERK_t ./ (aERK_t+ERK_t);

    r(exp,:)=(mod_fract-fract(exp));

end

averageSquaredDiff = (r(:)./ numel(targetIndices)).^2;

r2=sqrt(sum(averageSquaredDiff));

end