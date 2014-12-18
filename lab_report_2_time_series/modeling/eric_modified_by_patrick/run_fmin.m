clear,clc;
% get the IO diretories and such
prheenan_global_defines

toSaveAs = [fMinDir fminFileSave];
force = true;
if (fileExists(toSaveAs) && ~force)
    load(toSaveAs);
else
    fprintf('File %s did not exist, re-running...\n',toSaveAs);
    
    [conc,params,initial_conditions,conc2,ERKt] = loadConcs();
    
    equ_fract=.21;
    egf_fract=.48;

    fract=[equ_fract; egf_fract];
    EGF_conc=[0; 100];%in Molar
    tf=[600 700 800];
    inhib=[1,1];
    conc2(inhib(1))=inhib(2);

    time_course = 0:801;
    tp=1;te=500;
    
    res = runFMinCon( params,initial_conditions,EGF_conc,inhib,...
                    time_course,te,tp,fract,tf,conc,conc2);

end
% save everything we need
save(toSaveAs);
disp('Finished analyzing, Starting histograms and such.');
f = figure('Visible','off');
perDiff = abs(res-params) ./ min(res,params);
numBins = 10;
hist(perDiff ,numBins );
xlabel('variation from initial params',plotStruct{:})
ylabel('count',plotStruct{:})
title('Variation Histogram: few fitted parameters changed from initial values',plotStruct{:})
saveFigure(f,[fMinDir 'model_hist']);





