function [ output_args ] = AnalyzeCSV(  )
    clear; clc; close all; reset(gca);
    timecourseFolders = {'output0hr','output6hr'};
    activityMatrixRegex = '*_activity_means_over_t_and_conc.csv';
    activityMatrixRegexStdev = '*_activity_stdevs_over_t_and_conc.csv';
    IC50Matrix = '*IC50[pM]*hr*.csv';
    baseFolder = 'fall_2014/foundations_phys_7000_code/';
    searchFolder = [baseFolder  'computeOutput/'];
    outputFolder =  [baseFolder 'outputCSV'] ;
    ensureDirExists(outputFolder);
    numFolders = numel(timecourseFolders);
    activityFiles = cell(numFolders,1);
    activityFilesStd= cell(numFolders,1);
    IC50Files = cell(numFolders,1);
    parfor f=1:numFolders
        baseSearch = [searchFolder timecourseFolders{f} '/*'];
        tmpActivity = [baseSearch activityMatrixRegex];
        tmpActivityStd = [baseSearch activityMatrixRegexStdev];
        tmpIC50 = [baseSearch IC50Matrix];
        activityFiles{f} = GetAllFiles(baseFolder,tmpActivity);
        IC50Files{f} = GetAllFiles(baseFolder,tmpIC50);
        activityFilesStd{f} = GetAllFiles(baseFolder,tmpActivityStd);
    end
    % post: got all the files
    % XXX check they are the same size?
    rowOffset = 1;
    colOffset = 0;
    timeCol = 1;
    
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
    
    parfor f=1:numFolders
        actArr=activityFiles{f};
        stdArr =activityFilesStd{f};
        IC50Arr = IC50Files{f};
        numActivities = numel(actArr);
        numIC50s = numel(IC50Arr);
        myOutDir = [outputFolder '/' timecourseFolders{f} '/'];
        ensureDirExists(myOutDir);
        for a = 1:numActivities
            fileName = actArr{a};
            mat = csvread(fileName,rowOffset,colOffset);
            times = mat(:,timeCol);
            activity = mat(:,timeCol+1:end);
            % stdev also has time, but ignore that column.
            stdevs = csvread(stdArr{a},rowOffset,colOffset+1);
            concs = inhibitorsConcs_pM(a,:);
            idString = ['Well ' inhibitorWell{a} ' Inhibitor' num2str(a,'%02d')];
            tmpDir = [myOutDir idString '/'];
            ensureDirExists(tmpDir);
            plotActivity( times,concs,activity,stdevs, ...
                tmpDir , myOutDir, frameRateUnits,idString,concLabels );
        end

    end

end

