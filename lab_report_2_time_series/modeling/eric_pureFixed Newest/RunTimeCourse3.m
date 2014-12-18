function [] = RunTimeCourse3 ()
    clear,clc
    close all;
    prheenan_global_defines
    %whether or not to force manual recalc
    force = false;

    [conc,params,initial_conditions,~,ERKt] = loadConcs();

    equ_fract=.21;
    egf_fract=.48;

    %Load model values

    inhibitorLabels = {'B','C','D','E','F','G'};
    % one for EQ, ten for concs.
    course=[1:11];
    time_observe = 800;
    tpArr=[10,360];
    time_course=0:time_observe+max(tpArr);
    defEGF = 100;
    % when to add egf
    te=10;
    % when to perturb the system.
    conc2=conc(:,1);
    %%

    numTimes = numel(time_course);
    numSpecies = numel(initial_conditions);
    numTrials = numel(course);

    for inhibitor=1:6
        inhibitorRow = inhibitorLabels{inhibitor};
        idStr = ['Inhib' num2str(inhibitor)  ];
        toSave = [timeCourseDir timeCourse3FileSave idStr '.mat'];
        [y_vals0Hr,y_vals6Hr] = getFunction(inhibitor,params,initial_conditions,...
                defEGF,time_course,te,tpArr,conc,numTimes,...
                numSpecies,numTrials,course,toSave,force);
        erkCol = 11;

        tp0hr = tpArr(1);
        tp6hr = tpArr(2);
        time0Hr = tp0hr:tp0hr+time_observe-1;
        time6Hr = tp6hr:tp6hr+time_observe-1;
        
        erk0Hr = y_vals0Hr(time0Hr,11,:);
        erk6Hr = y_vals6Hr(time6Hr,erkCol,:);
        allErk = cat(1,erk0Hr,erk6Hr);
        allErk = allErk(:);
            %%
            % XXX for now, just get the 0hr ys...
        save(toSave);
        fig1 = figure('Visible','Off');
        ErkToPlot0hr = reshape(erk0Hr,time_observe,numTrials);
        ErkToPlot6hr = reshape(erk6Hr,time_observe,numTrials);
        minV = min(allErk)*0.95;
        maxV = max(allErk)*1.05;  
        ax1 = subplot(1,2,1);
        [legH, legL] = plotAndLabel(ErkToPlot0hr,numTrials,conc,inhibitor,tp0hr,...
                            time0Hr,time_observe,[idStr 'added at time ' num2str(tp0hr) '(~0hr).'],false);
        p2 = plot([0,0],[0,0]);
        set(p2,'Visible','off');
        legend(legH,legL,'Location','SouthWest');
        ax3 = subplot(1,2,2);
        plotAndLabel(ErkToPlot6hr,numTrials,conc,inhibitor,tp6hr,...
                            time6Hr,time_observe,[idStr 'added at time' num2str(tp6hr) '(~6hr).'],false); 
         ylim(ax1,[minV,maxV])
        ylim(ax3,[minV,maxV])
                        
        saveFigure(fig1,[timeCourseDir 'fig1.ERK_V_time_' idStr],'png');
        %% 
        fig2 = figure('Visible','Off');
        hold all;
        plot(time0Hr,ErkToPlot0hr(:,1),'b')
        plot(time0Hr,ErkToPlot0hr(:,2),'g')
        line(get(gca,'Xlim'),[ERKt*equ_fract ERKt*equ_fract],'color','k','linestyle','--')
        line(get(gca,'Xlim'),[ERKt*egf_fract ERKt*egf_fract],'color','k','linestyle',':')
        xlabel('time (arb)',plotStruct{:})
        ylabel('erk activity (arb)',plotStruct{:});
        legend('equ simulation','EGF simulation','equilibrium','100pM egf',...
            'Location','East')
        saveFigure(fig2,[timeCourseDir 'fig1.ERK_V_timeII_' idStr],'png');
        %toc
        %% plot just the EGF in the first and second trials

        vis=17;
        fig3 = figure('Visible','Off');
        % equilibrium
        plot(time_course,y_vals0Hr(:,vis,1),'b')
        hold all
        % egf (should skyrocket)
        plot(time_course,y_vals0Hr(:,vis,2),'g')
        xlabel('time (arb)',plotStruct{:});
        ylabel('EGF (arb)',plotStruct{:})
        saveFigure(fig3,[timeCourseDir 'fig3.EGF_timeII_' idStr],'png');

        %time_course = 0:801;
        %tp=1;te=500;
        %res=fminsearch(@(params) func3_fmin(params,initial_conditions,EGF_conc,inhib,time_course,te,tp,fract,tf),params,opts);


    end

end

function [handles,labels] = plotAndLabel(ErkToPlot,numTrials,conc,...
                            inhibitor,tp,time_course,numTimes,idStr,...
                            legendBool)
        % one for each trial, one for TP, one for common
        numToPlot = numTrials+1;
        labels = cell(1,numToPlot);
        handles = zeros(1,numToPlot);
        hold all;
        % go through each trial (including an eq one) and plot
         cmap = colormap(winter(numTrials));
        timeObs = 1:numTimes;
        for i=1:numTrials
            if i==1
                h = plot(timeObs,ErkToPlot(:,i),'k');
                labStr = 'equil';
            else
                h = plot(timeObs,ErkToPlot(:,i),'-','Color',cmap(i,:));
                labStr = [ num2str(conc(inhibitor,i-1),'%.2g') 'pM']; 
            end
            handles(i) = h;
            labels{i} = labStr;   
        end
        % add legends and a time showing the perturbation time T_p
        handles(end) = line([0,0],get(gca,'Ylim'),'color','k','linestyle','--');
        tpStr =  num2str(tp,'%d');
        labels{end} = ['T_p at ' tpStr];
        if (legendBool)
            legend(handles,labels,'Location','eastOutside');
        end
        xlabel(['Time (arb) since inhibitor addition at T_p=' tpStr]);
        ylabel('active ERK (arb)');
        title(idStr) 
end

function [y_vals0Hr,y_vals6Hr] = getFunction(inhibitor,params,initial_conditions,...
                defEGF,time_course,te,tpArr,conc,numTimes,...
                numSpecies,numTrials,course,toSave,force)

        if (fileExists(toSave) && ~force)
            load(toSave);
            fprintf('Found file %s. \n',toSave);
        else
            fprintf('Couldnt find file %s. \nGoing to re-calculate everything.\n',toSave);
           y_vals0Hr = getFunctionHelper(inhibitor,params,initial_conditions,...
                defEGF,time_course,te,tpArr(1),conc,numTimes,...
                numSpecies,numTrials,course);
           y_vals6Hr = getFunctionHelper(inhibitor,params,initial_conditions,...
                defEGF,time_course,te,tpArr(2),conc,numTimes,...
                numSpecies,numTrials,course);
        end
end
               

function [y_vals] = getFunctionHelper(inhibitor,params,initial_conditions,...
                defEGF,time_course,te,tp,conc,numTimes,...
                numSpecies,numTrials,course)
    % y_vals needs data for each time, species, trial, and
    % perturbation time (ie: 0 and 2 hours)
    y_vals = zeros(numTimes,numSpecies,numTrials);
    waitb=waitbar(0);
    courseNum = 1;
    for i=course
        waitb=waitbar(i/11,waitb,int2str(i));
        inhib=[1,1];
        conc2=conc(:,1);
        if i==1
            EGF_conc=0;
        else
            EGF_conc=defEGF;
            inhib=[inhibitor,i-1];
        end
        [~, y_vals(:,:,courseNum)]=func2_TimeCourse(params,uint64(initial_conditions),...
            EGF_conc,inhib,time_course,te,tp,conc,conc2);
        courseNum = courseNum +1;
    end
    close(waitb)
 end



