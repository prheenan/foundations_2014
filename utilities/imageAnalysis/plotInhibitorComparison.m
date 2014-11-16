function [  ] = plotInhibitorComparison( globalBase, numFolders, ...
    numInhibitors, numTimesPerFolder,IC50MeanStdevTime,timeStr,wells  )


    inhibColors = {'r','b','k','m','c','g'};
    folderShapes = {'rx','bo'};
    
    IC50MeanStdevEquilibrium = zeros(numInhibitors,2,numFolders);

    % IC50MeanStdevTime has a [Row,Column,Matrix,Matrix'] =  
    % [numInhibitors,max(numTimesPerFolder{:}),[mean,stdev,times],numFolders ] 

    inhibArr = (1:numInhibitors)';
    % for plotting the mean IC50 and stdev at Equilibirum
    fig = figure('Position',[0,0,1000,800],'Visible','Off');
    for i=1:numFolders
      [ tmpEqIC50Mean,tmpEqIC50Stdev, ~, ~] = ... 
               getSteadyState( IC50MeanStdevTime(:,:,1,i));

        IC50MeanStdevEquilibrium(:,1,i) = tmpEqIC50Mean;
        IC50MeanStdevEquilibrium(:,2,i) = tmpEqIC50Stdev;

        % default markersize is 6
        errorbar(inhibArr,tmpEqIC50Mean,tmpEqIC50Stdev, ...
            folderShapes{i},'MarkerSize',16);
        hold on;
    end
  plotStruct = {'FontSize',16};
  title('IC50 versus Inhibitor, adding inhibitor at time 0 (x) and 6 (o) hours',plotStruct{:});
  xlabel('Inhibitor number',plotStruct{:});
  ylabel('IC50 [pM]',plotStruct{:});
  set(gca,'YScale','log');
  legend('Inhib @ 0hr','Inhib @ 6hr','Location','eastoutside');
  saveFigure( fig,[globalBase 'EQ_IC50_versus_inhibitor']);

    fig = figure('Position',[0,0,1800,1600],'Visible','Off');
    allMeans = IC50MeanStdevTime(:,:,1,:);
    ylimits = [min(allMeans(:))*0.9,max(allMeans(:))*1.1];

    for i=1:numFolders
        % if i=0, then 0hr. If i=1, then 6hr. XXX fix this if generalizing.
        hourStr = [num2str((i-1)*6,'%1d') 'hr'];
        csvFileName = ['IC50[pM],' hourStr];
        subplot(numFolders,1,i);
        title([csvFileName ' versus ' timeStr],plotStruct{:});
        hold on;
        timesCheck = 1:numTimesPerFolder{i};
         IC50MeanThisFolder = IC50MeanStdevTime(:,timesCheck,1,i);
         ylim(ylimits);
         IC50StdevThisFolder = IC50MeanStdevTime(:,timesCheck,2,i);
         % times should all be the same, so just pick the first inhibitor.
         IC50TimesThisFolder = IC50MeanStdevTime(1,timesCheck,3,i);
         legendStr = cell(1,numInhibitors);
         simpleStr = cell(1,numInhibitors);
        for inhib = 1:numInhibitors
            IC50ThisInhib = IC50MeanThisFolder(inhib,:);
            goodIndices = (IC50ThisInhib > 0);
            % x axis should be times
            goodTimes  = IC50TimesThisFolder;
            goodIC50 = IC50ThisInhib(goodIndices);
            
            inhibFormat = [inhibColors{inhib} 'o-'];
            % XXX add in error?
            %goodStdev = IC50StdevThisFolder(goodIndices);
            %stdevFormat = [inhibColors{inhib} '--'];
            %plot(goodTimes,goodIC50-goodStdev,[stdevFormat]);
            plot(goodTimes,goodIC50,inhibFormat);
            %plot(goodTimes,goodIC50+goodStdev,[stdevFormat]);
            set(gca,'YScale','log');
            % XXX need to fix this to use actual time
            xlabel(timeStr,plotStruct{:});
            ylabel('IC50 [pM]',plotStruct{:});
            IC50Str = [ num2str(IC50MeanStdevEquilibrium(inhib,1,i),'%.1g')  177 ...
                        num2str(IC50MeanStdevEquilibrium(inhib,2,i),'%.1g')];
            simpleStr{inhib} = [' Inhib' num2str(inhib,'%2d')];
            legendStr{inhib} = [wells{inhib} simpleStr{inhib} ];
        end
        grid on;
        grid minor;
        tmpName =[globalBase csvFileName ];
        writeMatrixColLabel([tmpName '_mean'],...
            IC50MeanThisFolder',legendStr,IC50TimesThisFolder,timeStr);
        writeMatrixColLabel([tmpName '_std'],...
            IC50StdevThisFolder',legendStr,IC50TimesThisFolder,timeStr);
        legend(legendStr,'Location','eastoutside');
    end
            
    fileName = [globalBase 'IC50_over_time_both_0hr_and_6hr'];
    saveFigure( fig, fileName);

    % reshape such that we concatenate all the rows in the stdev and mean.
    % this have the effect of putting the 0hr and 6hr side by side. I hope.
    flattened0Hr6HrMeans = reshape(IC50MeanStdevEquilibrium(:,1,:),[numInhibitors,numFolders]);
    flattened0Hr6HrStdevs = reshape(IC50MeanStdevEquilibrium(:,2,:),[numInhibitors,numFolders]);
    
    hourLabels = {'0hr','6hr'};
    writeMatrixColLabel([tmpName 'EQ_IC50pm_Means'],flattened0Hr6HrMeans,...
        hourLabels,inhibArr,simpleStr);
    writeMatrixColLabel([tmpName 'EQ_IC50pm_Stdevs'],flattened0Hr6HrStdevs,...
    hourLabels,inhibArr,simpleStr);


end

