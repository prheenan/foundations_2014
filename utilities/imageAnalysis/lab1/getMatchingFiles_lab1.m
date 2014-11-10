
function [intsRatio,stdevRatio]  = getMatchingFiles(imageFolder,regexC1,regexC2,blankC1,blankC2,conc)
    % --imageFolder: Folder to look for images
    % --regexC1: all the channel 1 regexes (eg "*w1*.serum.tif" ) for finding
    % this trials images. Can be multi dimensional (eg: {
    % "*w1*.serum.tif","*w1*.noWerum.tif"} )
    % --regexC1: all the channel 1 regexes (eg "*w2*.serum.tif" ) for finding
    % this trials images. Can be multi dimensional (eg: {
    % "*w2*.serum.tif","*w2*.noWerum.tif"} )    
    % --blankC1: a 'blank' matrix for all the channel ones XXX change to
    % well-based?
    % -- blankC2 a 'blank' matrix for all the channel twos XXX change to
    % well-based?
    % -- conc: the concentrations to use..

    
    % assume we have multiple inhibitors, get the ratios for all of them...
    % notee: we assume we have the same number of files in each channel
   startNum = 2;
   % get the number of trials, we assume equal on both channels
   % e.g. for inhibited and uninhibited, have two channels
   numTrials = numel(regexC1);
   numPoints = numel(conc);
    % go through each trial (e.g. inhibited and uninhibited)
    % and get the mean ratio
    intsRatio = zeros(numTrials,numPoints);
    stdevRatio = zeros(numTrials,numPoints);
    for t=1:numTrials
        % go through each 'trial' (e.g. serum vs noSerum)
       for p=1:numPoints
           % go through all the concentrations in a trial (e.g. serum @
           % 10pM, serum at 20pM, etc)
           index = num2str(p-1+startNum,'%d');
           regexStr1 = strcat(imageFolder,'*',index,regexC1{t});
           regexStr2 = strcat(imageFolder,'*',index,regexC2{t});
           files1 = dir(regexStr1);
           files2 = dir(regexStr2);
            % again, assume the number of files is the same...
            numFiles = size(files1,1);
            if (numFiles == 0)
                fprintf('In getMatchingFiles, Could not found file like %s! Exiting...',regexStr1);
                
            end
            numObj = 0;
            maxNumObj = 300;
            cellInts = zeros(maxNumObj,numFiles);
            % one concentration has multiple files, look at all of them and
            % average
            for j=1:numFiles
                % look at all the matches
                fileNameC1 = [imageFolder files1(j).name];
                fileNameC2 = [imageFolder files2(j).name];
                fprintf('Processing %10s with %10s\n',fileNameC1,fileNameC2);
                % get the intensity ratio
                [newIntRatio,newNumObj,bin,foundNuclei]= readAndOptimize(fileNameC1,fileNameC2,blankC1,blankC2,imageFolder);
                numObj = numObj + newNumObj;
                % add this intensity ratio! for plotting later.
                cellInts(1:newNumObj,j) = newIntRatio';
            end
            % get the stats for this concentration
            cellInts = cellInts(cellInts > 0);
            fileStd = std(cellInts(:));
            fileMean = mean(cellInts(:));
            strToPrint = sprintf('\nFile like [%15s] has [I_0,N_obj]=[%6.5g,%3d obj]\n', ...
                strcat(index,regexC1{t}),fileMean,numObj);
            fprintf(strToPrint);
            intsRatio(t,p) = fileMean;
            stdevRatio(t,p) = fileStd;
       end
    end
end

