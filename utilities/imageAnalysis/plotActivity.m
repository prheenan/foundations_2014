function [timeCourseIC50s_mean_stdev_times ] =  ...
    plotActivity( timesAvg,concentrations, meanAllConc,stdevAllConc, ...
    IC50InhibDir , globalOutputDir, frameRateUnits,idString,concLabels )
    % meanAllConc: size is (numTimes,numConcentrations);
    % timeAverage: the times (numTimes) to plot on the x axis, 
    % initializ the IC50 as -1; if an IC50 could not be fit, this array
    % will be <0 still.
    
    plotStruct = {};
    numTimes = numel(timesAvg);
    numConcs = numel(concLabels);
    IC50sRaw = -1 .* ones(numTimes,1);
    IC50stdRaw = .1 .* ones(numTimes,1);

    for t = 1:numTimes
        times = timesAvg(t);
        % get the mean and stdev across all concentrations...
        means = meanAllConc(t,:);
        stdevs = stdevAllConc(t,:);    

        titlePlot = ['IC50 for ' idString ',' num2str(times,'%.2f') ' '  frameRateUnits ];
        saveName = [IC50InhibDir 'Frame_' num2str(t-1,'%02d')];
       [ IC50sRaw(t) , IC50stdRaw(t)] = normalizeAndPlot_lab1(concentrations,means,stdevs,...
            saveName,titlePlot,true,'Inhibitor');
    end
    reset(gca);
    close all;
    clf;

    fig = figure('Position',[0,0,1600,1200],'Visible','Off');
    numPlots =4;
    plotCounter = 1;
    timeStr = ['Time(' frameRateUnits ')'];

    goodIndices= (IC50sRaw > 0);
    % only look at time points greater than one, which were fitable
    goodIndices = (goodIndices);
    IC50s = IC50sRaw(goodIndices);
    IC50std = IC50stdRaw(goodIndices);
    timesIC50 = timesAvg(goodIndices);
    timeCourseIC50s_mean_stdev_times = [IC50s,IC50std, timesIC50];
    
    activityStr = ['Activity(Au)'];
    ax1 = subplot(numPlots,1,plotCounter);
    title(['Activity and IC50s for ' idString ]);
    hold on;
    cmap = colormap(ax1,hot(numTimes));
    % default line width is 0.5
    heatMapStruct = {'Marker','o','LineStyle','-','MarkerEdgeColor','b',...
                     'MarkerSize',2,'LineWidth',0.25};
    ylimits = [min(meanAllConc(:))*0.8,max(meanAllConc(:)*1.05)];
    for t = 1:numTimes
        plot(concentrations,meanAllConc(t,:),'Color',cmap(t,:), ...
        heatMapStruct{:},'MarkerFaceColor',cmap(t,:));
    end
    grid on;
    grid minor;
    set(gca,'XScale','log');
    colorRange = [timesAvg(1),timesAvg(numTimes)];
    caxis(colorRange);
    h = colorbar('eastoutside');
    set(get(h,'ylabel'),'string','[Time (Min)]');
    ylabel(activityStr);
    xlabel('Concentation [pM]');
    plotCounter = plotCounter + 1;
    ylim(ylimits);

    subplot(numPlots,1,plotCounter);
    hold on;
    for conc = 1:numConcs
        colorIndex = max(1,round((numTimes/numConcs) * conc));
        plot(timesAvg,meanAllConc(:,conc),'Color',cmap(colorIndex,:),...
            heatMapStruct{:},'MarkerFaceColor',cmap(colorIndex,:));
    end
    colorRange = [concentrations(1),max(concentrations(numConcs))];
    caxis(colorRange);
    h = colorbar('eastoutside');
    set(get(h,'ylabel'),'string','[Conc (pM)]');
    xlabel(timeStr);
    ylabel(activityStr);
    plotCounter = plotCounter + 1;
    ylim(ylimits);
    grid on;
    grid minor;

    subplot(numPlots,1,plotCounter);
    errorbar(timesIC50,IC50s,IC50std,'ro-');
    xlimits = [ 0.95*min(timesIC50), max(timesIC50)*1.05];
    xlabel(timeStr,plotStruct{:});
    ylabel('IC50',plotStruct{:}); 
    title(['IC50 (pM) versus ' timeStr],plotStruct{:});
    ax = gca;
    grid on;
    grid minor;
    set(ax,'YScale','log');
    disp(xlimits);
    xlim(xlimits);
    plotCounter = plotCounter + 1;

    subplot(numPlots,1,plotCounter);
    % plot the last half. IC50s is a column vector, so transpose (only
    % one inhibitor)
    [ meanIC50Steady, stdIC50Steady, IC50Slice, slice] = ...
            getSteadyState( IC50s' );
    steadyStateIC50s_mean_stdev = [meanIC50Steady, stdIC50Steady];
    hold all;
    title(['Equilibrium IC50[pm]:' num2str(meanIC50Steady,'%.2g') '+/-' num2str(stdIC50Steady,'%.2g')]);
    errorbar(timesIC50(slice),IC50Slice,IC50std(slice),'ro-');
    axhline(xlimits,meanIC50Steady,'k');
    lowerBound = meanIC50Steady-stdIC50Steady;
    upperBound =meanIC50Steady+stdIC50Steady;
    axhline(xlimits,lowerBound,'b');
    axhline(xlimits,upperBound,'b');
    xlim(xlimits);
    xlabel(timeStr,plotStruct{:});
    ylabel('IC50',plotStruct{:}); 
    idIC50Plot =  ['FullIC50Plot' idString];

    fileNameIC50 = [IC50InhibDir idIC50Plot];
    plotCounter = plotCounter + 1;       
    writeMatrixColLabel([fileNameIC50 '_IC50pM_and_stdevs'],[IC50s , IC50std], ...
        {'IC50 mean[pM]','IC50 std[pM]'},timesIC50,timeStr);

    writeMatrixColLabel([IC50InhibDir idString '_activity_means_over_t_and_conc'], ...
        meanAllConc,concLabels,timesIC50,timeStr);
    writeMatrixColLabel([IC50InhibDir idString '_activity_stdevs_over_t_and_conc'], ...
        stdevAllConc,concLabels,timesIC50,timeStr);
    % save the graph in two places...
    saveFigure(fig,fileNameIC50);
    saveAndCloseFigure(fig,[globalOutputDir idIC50Plot]); 
    clf;

end

