function [ output_args ] = AnalyzeCSV(  )
    clear; clc; close all; 
    timecourseFolders = {'output0hr','output6hr'};
    activityMatrixRegex = '*_activity_means_over_t_and_conc.csv';
    activityMatrixRegexStdev = '*_activity_stdevs_over_t_and_conc.csv';
    IC50Matrix = '*IC50[pM]*hr*.csv';
    baseFolder = 'fall_2014/foundations_phys_7000_code/';
    searchFolder = [baseFolder  'computeOutput/'];
    outputFolder =  [baseFolder 'outputCSV'] ;
    cachedFile = [outputFolder  '/filesUsed.mat']; 
    ensureDirExists(outputFolder);
    % 1 row is headers
    rowOffset = 1;
    colOffset = 0;
    % first column is time in all files.
    timeCol = 1;
    force = false;
    if (~fileExists(cachedFile) || force)
        numFolders = numel(timecourseFolders);
        activityFiles = cell(numFolders,1);
        activityFilesStd= cell(numFolders,1);
        IC50Files = cell(numFolders,1);
        for f=1:numFolders
            baseSearch = [searchFolder timecourseFolders{f} '/*'];
            tmpActivity = [baseSearch activityMatrixRegex];
            tmpActivityStd = [baseSearch activityMatrixRegexStdev];
            tmpIC50 = [baseSearch IC50Matrix];
            activityFiles{f} = GetAllFiles(baseFolder,tmpActivity);
            IC50Files{f} = GetAllFiles(baseFolder,tmpIC50);
            activityFilesStd{f} = GetAllFiles(baseFolder,tmpActivityStd);
        end
        % get the min and max activity...
        % get the number of 0 and 6 hour files...
        numFiles = numel(activityFiles{1});
        minAct = inf;
        maxAct = 0;
        for i=1:numFiles
            for j=1:numFolders
                [act,~] = getFileInfo(activityFiles{j}{i},timeCol,...
                                      rowOffset,colOffset);
                allActMin = [act(:)',minAct];
                allActMax = [act(:)',maxAct];
                minAct = min(allActMin);
                maxAct = max(allActMax);
            end
        end
    else
       load(cachedFile) 
    end
    % post: got all the files
    % XXX check they are the same size?
    save(cachedFile);
    inhibitorsConcs_pM = [
    0	156.25      312.5       625     	1250	2500	5000	10000	20000	40000;   
    0	156.25      312.5       625         1250	2500	5000	10000	20000	40000;
    0	29.29688	58.59375	117.1875	234.375	468.75	937.5	1875	3750	7500;
    0	19.53125	39.0625     78.125      156.25	312.5	625 	1250	2500	5000;
    0	15.625      31.25       62.5        125     250     500 	1000	2000	4000;
    0	19.53125	39.0625     78.125      156.25	312.5	625 	1250	2500	5000;
    0	31.25       62.5        125         250     500     1000	2000	4000	8000];
    
    inhibitorWell = {'B','C','D','E','F','G'};
    frameRateUnits = 'Minutes';
    numConcs = size(inhibitorsConcs_pM,2);
    concLabels = cell(numConcs,1);
    for i=1:numConcs
        concLabels{i} = 'Conc 1';
    end
    
    numTimesPerFolders = {23,20};

    maxWidth = 1000;
    maxHeight = 800;
    figWidth = 0.33;
    figHeight = 0.8;
    ylimits = [minAct*0.8,maxAct*1.05];
    xlimits = [-10,400];
    titleStr = 'ERK activity for ';
    for i=1:numFiles
        idStr = getID(i,inhibitorWell);
        fig = figure('Visible','Off','Position',[0,0,maxWidth,maxHeight]);
        % get the time and activity values
        [act0,time0] = getFileInfo(activityFiles{1}{i},timeCol,rowOffset,colOffset);
        [act6,time6] = getFileInfo(activityFiles{2}{i},timeCol,rowOffset,colOffset);
        std0 = csvread(activityFilesStd{1}{i},rowOffset,colOffset+1);
        std6 = csvread(activityFilesStd{2}{i},rowOffset,colOffset+1);
        conc = inhibitorsConcs_pM(i,:);

        subplot(1,2,1,'Position',[0.075,0.1,figWidth,figHeight])
        plotConcOverTime(time0,act0,conc,std0);
        ylim(ylimits)
        xlim(xlimits);
        % add a legend to the first plot
        hlines(minAct,maxAct,act0,i,inhibitorWell,'0hr',time0);
        
        subplot(1,2,2,'Position',[0.55,0.1,figWidth,figHeight])
        plotConcOverTime(time6,act6,conc,std6);
        ylim(ylimits)
        xlim(xlimits);
        hlines(minAct,maxAct,act6,i,inhibitorWell,'6hr',time6);
        saveAndCloseFigure(fig,[outputFolder '/' idStr],'png'); 
    end
     

end

function [] = hlines(globalMin,globalMax,act,inhibitorIndex,wells,timeAdded,time)

    numTimes = size(act,1);
    eqStart = round(numTimes/4);
    localAct = act(eqStart:end,:);
    myMin = min(localAct(:));
    myMax = max(localAct(:));
    startTime = time(eqStart);
    lw = 1.5;
    lines = {'LineWidth',lw};
    plotStructActivity = {'k--',lines{:}};
    plotStructTime = {'r--',lines{:}};
    axTime = axvline(startTime,ylim,plotStructTime);
    axvline(max(time),ylim,plotStructTime);
    axhline(xlim,globalMin,plotStructActivity);
    axHigh = axhline(xlim,globalMax,plotStructActivity);
    
    actStr = sprintf('Activity Range, All Inhibitors: %.2f to %.2f [au]',globalMin,globalMax);
    timeStr = sprintf('Time for ERK Range: %3d to %3d [mins]',round(startTime),round(max(time)));
    legend([axHigh,axTime],...
            {actStr,timeStr},...
            'Location','NorthOutside');
    rangeStr = sprintf('ERK Range %.1f to %.1f, Change: %.2f',...
                        myMin,myMax,myMax-myMin);
    idStr = getID(inhibitorIndex,wells);
    title([idStr ' added at ' timeAdded char(10) rangeStr]);
    % print the caption
    if (timeAdded == '0hr')
        fprintf(['Figure 6.' num2str(inhibitorIndex,'%1d') ...
            ', Activity vs time for all concentrations for ' idStr ...
            ' with an activity of ' rangeStr ...
            '. The range is calculated within the bounds of ' ...
            'the red and black dotted lines.\n']);
    end
end

function [id] = getID(idx,inhibitorWell)
    id = ['Row ' inhibitorWell{idx} ' Inhib' num2str(idx,'%02d')];
end

function [activity,times] = getFileInfo(fileAct,timeCol,rowOffset,colOffset)
    hr = csvread(fileAct,rowOffset,colOffset);
    times = hr(:,timeCol);
    activity = hr(:,timeCol+1:end);
end
