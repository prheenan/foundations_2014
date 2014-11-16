function [] = lab2_wrapper(debugging,cluster,centroids)

addpath(genpath('../utilities/'));

% for debugging option, we use significantly less wells, just a '
if debugging
    numTimes={23}; 
    wells = {'G' 'C'};
    wellNumbers = 6:7; 
else
   wells = {'B' 'C' 'D' 'E' 'F' 'G'};  
   numTimes={23 , 19};
   %wells = {'B' 'C'};  
   wellNumbers = 2:11;
end
% path where to look for images / put output
baseFolder = {};
% path, where the images are
imageFolder = {};
% output path, where to place the images. should *not* end with a slash,
% since we increment it each time.
outputFolder = {};

frameRateUnits = 'Minutes';
timeStr = ['Time (' frameRateUnits ')'];

% cluster and personal PC have diferent settings. 
% see descriptions of folders above
if (cluster)
    baseFolder = {'../../' , '../../' };
    base = baseFolder{1};
    imageFolder= { [base 'Inhibitor Timecourses/0hr/'],[base 'Inhibitor Timecourses/6hr/']};
    outputFolder = { [base 'output0hr'] , [base 'output6hr'] };
    frameRates = { 16.3 , 20}; 
else    
    baseFolder = {'fall_2014/foundations_phys_7000_code/lab_report_2_time_series/'};
    base = baseFolder{1};
    imageFolder= { [base 'test images/'] };
    outputFolder =  { [base 'output'] };
    frameRates = {16.3};
end  

    % run all the wells we want.
    numInhibs = numel(wells);
    numFolders = numel(imageFolder);

    % mean, stdev, and time for each inhibitor, for each folder, over time
    IC50MeanStdevTime = ones(numInhibs,max(numTimes{:}),3,numFolders) .* -1;

    % XXX get the average stdevs and means for IC50s
    dirTmp = outputFolder{1};
    hold on;
    for i=1:numFolders
        dirTmp = outputFolder{i};
        count = 1;
        while (allDirsExist(dirTmp))
           dirTmp = [outputFolder{i} num2str(count,'%3d')];
           count = count + 1;
        end
        dirTmp = [dirTmp '/']; % add the trailing paren
        ensureDirExists(dirTmp);
        timesThisDir = numTimes{i};
        % post: found an output directory.
        tmpTimeCourse  = ...
            lab2_func(baseFolder{i},imageFolder{i},dirTmp,timesThisDir,...
            wellNumbers,wells,centroids,frameRates{i},frameRateUnits);  
        IC50MeanStdevTime(:,1:timesThisDir,:,i) = tmpTimeCourse;

    end
    % globalBase is where to save global results...
    globalBase = [dirTmp '/'];
    plotInhibitorComparison( globalBase, numFolders, ...
        numInhibs, numTimes,IC50MeanStdevTime,timeStr,wells  )

end
