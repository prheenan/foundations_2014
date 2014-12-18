clear,clc
close all;
prheenan_global_defines
%whether or not to force manual recalc
force = true;

inhibitorLabels = {'B','C','D','E','F','G'};

[conc,parms,initial_conditions,~,ERKt] = loadConcs();

% from immunofluorescence 
equ_fract=.21;
egf_fract=.48;

% initialize the concentrations to 0.
conc2=conc(:,1);
%%
time_course=0:1000;
% time in sim iters to add EGF
te=10;
% time in sim iters to perturb with inhibitor
tp=300;
% number of inhibitors (?)
numTrials = 11;
numTimes = numel(time_course);
numConcs = numel(initial_conditions);
numInhibitors = 6;
    
for inhibitor=[1,2,4,5,6];
        inhibitorRow = inhibitorLabels{inhibitor};
        idStr = ['Inhibitor#' num2str(inhibitor) ' Row' inhibitorRow];
        toSave = [timeCourseDir timeCourse3FileSave idStr '.mat'];
        
        if (fileExists(toSave) && ~force)
            load(toSave);
        else
            % get the concentrations for all tria,s including an eq time
            % y_vals is the concentrations for wells 
            fprintf('Couldnt find file %s. \nGoing to re-calculate everything.\n',toSave);
            y_vals = zeros(numTimes,numConcs,numTrials);
            
            %% fmin returns some of percentage errors (between0 and 10). So, tolerance
            % is five percent tolerance per data point
            fract=[equ_fract; egf_fract];
            EGF_concFMin=[0; 100e-12];%in Molar
            % times to compare...
            tf=[600 650 700 750 800];
            inhibFMin=[inhibitor,1];
            conc2(inhibFMin(1))=inhibFMin(2);
            time_courseFmin = 0:801;
            tpFmin=1;teFmin=500;
            
            optParams = runFMinCon( parms,initial_conditions,EGF_concFMin,inhibFMin,...
                    time_courseFmin,teFmin,tpFmin,fract,tf,conc,conc2);
            
            for i=1:numTrials
                inhib=[1,1];
                % for the equilbirum, don't start off with any EGF 
                if i==1
                    EGF_conc=0;
                else
                    % use column one after the EQ trial, etc.
                    EGF_conc=100;
                    inhib=[inhibitor,i-1];
                end
                fprintf('For %s, Trial %d/%d Starting\n',idStr,i-1,numTrials);
                % get the concentrations for this trial
                [~, y_vals(:,:,i)]=func2_TimeCourse(optParams,initial_conditions,...
                                        EGF_conc,inhib,time_course,te,tp,conc,conc2);
            end

     end
        % save everything we need.
    save(toSave);
    

    fig1 = figure('Visible','Off');
    labels = cell(1,numTrials+1);
    hold all;
    ErkToPlot = reshape(y_vals(:,11,:),numTimes,numTrials);
    ax = subplot(1,1,1);
    % go through each trial (including an eq one) and plot
     cmap = colormap(hsv(numTrials));
     % add a single line for the (shared) status before perturbation
    plot(time_course(1:tp),ErkToPlot(1:tp,2),'r--');
    labels{1} = 'ERK(t < T_p) (shared)';
    for i=1:numTrials
        if i==1
            plot(time_course,ErkToPlot(:,i),'k');
            labels{i+1} = 'eq (no inhib or EGF)';
        else
            plot(time_course(tp:end),ErkToPlot(tp:end,i),'-','Color',cmap(i,:))
            labels{i+1} = [ num2str(conc(inhibitor,i-1),'%5.2f') 'pM']; 
        end
    end
    % add legends and a time showing the perturbation time T_p
    line([tp,tp],get(gca,'Ylim'),'color','k','linestyle','--')
    legend(labels{:},['T_p=' num2str(tp,'%d')],'Location','Southwest');
    xlabel('Time (arb)',plotStruct{:});
    ylabel('active ERK (arb)',plotStruct{:});
    title(['Equilibrium ERK activity is dependent on ' idStr ' at T_p'],plotStruct{:}) 
    saveFigure(fig1,[timeCourseDir 'fig1.ERK_V_time_' idStr]);
    %%, 
    fig2 = figure('Visible','Off');
    hold all
    plot(time_course,ErkToPlot(:,1),'b')
    plot(time_course,ErkToPlot(:,2),'g')
    line(get(gca,'Xlim'),[ERKt*equ_fract ERKt*equ_fract],'color','k','linestyle','--')
    line(get(gca,'Xlim'),[ERKt*egf_fract ERKt*egf_fract],'color','k','linestyle',':')
    xlabel('time (arb)',plotStruct{:})
    ylabel('erk activity (arb)',plotStruct{:});
    set(ax,'XScale','log');
    legend('equ simulation','EGF simulation','equilibrium','100pM egf')
    saveFigure(fig2,[timeCourseDir 'fig1.ERK_V_timeII_' idStr]);
    %toc
    %% plot just the EGF in the first and second trials

    vis=17;
    fig3 = figure('Visible','Off');
    % equilibrium
    plot(time_course,y_vals(:,vis,1),'b')
    hold all
    % egf (should skyrocket)
    plot(time_course,y_vals(:,vis,2),'g')
    xlabel('time (arb)',plotStruct{:});
    ylabel('EGF (arb)',plotStruct{:})
    saveFigure(fig3,[timeCourseDir 'fig3.EGF_timeII_' idStr]);

end






