function [ timeCourseIC50s_mean_stdev_times ] = lab2_func(baseFolder,imageFolder, ...
    outputFolder,numTimes,wellNumbers,wells,centroids,frameRate,frameRateUnits)

    numSites = 4;
    numWavelengths = 2;
    plotStruct = {};
    % get the blanks for flatfield correction; average them!
    % create the directories if they dont exist
    ensureDirExists(baseFolder);
    ensureDirExists(outputFolder);

    blankWells = {getWell('B',1) getWell('C',1) getWell('D',1)};
    if (~allDirsExist(imageFolder))
        fprintf('Couldn''t find image folder %s! Giving up...\n',imageFolder);
        return;
    end
    dirs = listSubDirectories(imageFolder);
    % get the blanks for all wavelengths and times
    blanks = getBlanks( imageFolder,blankWells,dirs,...
                        numTimes, numWavelengths);
    % start at time 1, consider this time 0
    % this is from correspondence with Eric Bunker, 11/6/2014:
    % "First timepoint of the image files is just before adding
    % inhibitor/egf (0hr) or just before adding inhibitor (6hr)."
    % The second timepoint I considered 0 minutes as I started it as soon 
    % as I'd pipetted everything in.
    startTime = 1;
    timesAvg = (0:numTimes-1)' .* frameRate;   

    numInhibitors = numel(wells);
    numConcs = numel(wellNumbers);
    % all inhibitor concentrations in pM
    inhibitors = [
    0	156.25      312.5       625     	1250	2500	5000	10000	20000	40000;   
    0	156.25      312.5       625         1250	2500	5000	10000	20000	40000;
    0	29.29688	58.59375	117.1875	234.375	468.75	937.5	1875	3750	7500;
    0	19.53125	39.0625     78.125      156.25	312.5	625 	1250	2500	5000;
    0	15.625      31.25       62.5        125     250     500 	1000	2000	4000;
    0	19.53125	39.0625     78.125      156.25	312.5	625 	1250	2500	5000;
    0	31.25       62.5        125         250     500     1000	2000	4000	8000];
    
   IC50LocBase = [outputFolder 'IC50s/'];
   ensureDirExists(IC50LocBase);
   
   traceBase = [outputFolder 'Traces/'];
   ensureDirExists(traceBase);
   
   initialTime = tic;
   % the folder relative to the matlab workspace where the images live
   regexFormatted='site %1d wavelength %1d t%02d.tif';
   % first column is mean, second is stdev
   steadyStateIC50s_mean_stdev = zeros(numInhibitors,2);
   timeCourseIC50s_mean_stdev_times= (-1 .* ones(numInhibitors,numTimes,3));
   
   parfor inhib=1:numInhibitors
        tmpWell = wells{inhib};
        idString = ['Inhib' num2str(inhib,'%02d') '_well_' tmpWell];
        IC50InhibDir = [ IC50LocBase idString '/'];
        ensureDirExists(IC50InhibDir);

        traceDir = [traceBase idString '/'];
        ensureDirExists(traceDir);
        concFolders = cell(numConcs,1);
        concLabels = cell(numConcs,1);

        concentrations = inhibitors(inhib,1:numel(wellNumbers)); 
        
        for conc = 1:numConcs
            wellName = getWell(tmpWell,wellNumbers(conc));
            thisConc= [imageFolder wellName '/'];
            concFolders{conc} = thisConc;
            concLabels{conc} = [idString '_Conc_' num2str( concentrations(conc),'%.5f') '_pM' ];
        end                 
        if (~allDirsExist(concFolders))
            fprintf('Couldn''t find all the folders for inhibitor %d, not bothering...\n',inhib);
            % XXX put this in later...
            continue;
        end
        [meanAllConc,stdevAllConc,centroidStats] = ...
                allSites(concFolders,outputFolder,regexFormatted, ...
                blanks, numWavelengths,numTimes,numSites, startTime,idString, ...
                initialTime,centroids);

        tmp =  ...
            plotActivity( timesAvg,concentrations, meanAllConc,stdevAllConc, ...
            IC50InhibDir , outputFolder, frameRateUnits,idString,concLabels  );
        timeCourseIC50s_mean_stdev_times(inhib,:,:) = tmp;
        % mean along the rows for the first two columns (mean and stdev) 
        steadyStateIC50s_mean_stdev(inhib,:) =  ...
            mean(tmp(:,1:2),1);
        
        if (centroids)
            for conc =1:numConcs
                means = meanAllConc(:,conc);
                stdevs = stdevAllConc(:,conc);
                well = getWell(tmpWell,wellNumbers(conc));
                wellBase = [traceDir well];
                 % XXX make constants for the indices
                 fprintf('Saving CSV of traces for %s, Time elapsed: %7.3f\n',well,toc(initialTime));
                 saveToCSV( [ wellBase '_SheetTraces.csv'], {catCellCol(centroidStats,1),...
                     catCellCol(centroidStats,4)}, ...
                    {'Frame', 'Int'}, [timesAvg,means, stdevs], ...
                        {'Mean Frames','Mean Int','Intensity Stdev'});   

                 f = figure('Position',[0,0,1200,1000],'Visible','Off');
                 hold all;
                 intMean  = means(:,1);
                 % default line width is 0.5...
                 errorbar(timesAvg,intMean, stdevs,'ro-','LineWidth',2.5);
                 title('Average FRET/CFP Ratio Over time',plotStruct{:});
                 ylabel('FRET/CFP',plotStruct{:});
                 xlabel(timeStr,plotStruct{:});
                fprintf('Plotting traces for %s, Time elapsed: %7.3f\n',well,toc(initialTime));
                siteColors = ['m','g','b','k'];
                for s=1:numSites
                    thisSite = centroidStats(s,:);
                    % XXX need to get rid of magic numbers for indices...
                    times = thisSite{1};
                    ints = thisSite{4};
                    ints = (ints);
                    numCells = numel(times);
                     for i=1:numCells
                         % XXX could normalize...
                         thisCellInt = ints{i};
                        % XXX plot error eventually. Sort into time bins...
                        %plotArr = sortrows([times{i},thisCellInt],1);
                        %plot(plotArr(:,1),plotArr(:,2),[siteColors(s) 'o-']);
                     end
                end
                axhline(timesAvg,0.5,'r');
                fprintf('Saving Plot traces for %s, Time elapsed: %7.3f\n',well,toc(initialTime));
                saveAndCloseFigure(f,[wellBase '_AllSites_OverTime']);                      
            end
        end
   end
   toWrite = [(1:numInhibitors)' steadyStateIC50s_mean_stdev];
   writeMatrix([outputFolder 'steadyStateIC50sAndStdevs'],toWrite, ...
       {'Inhibitor','Mean IC50 [pM]' ,'Stdev IC50 [pM]'});

    

end

function [means,stdevs,centroidFinalStats] = allSites(baseFolders,outFolder,...
      regexString,blankMatrices,numWavelengths,numTimes,numSites, startTime,...
      saveID,initialTime,centroids)
    % basefolders has one per concentration
    % regex string is just to fill in with the number of wavelengths and
    % times (and sites!)
    analysisDir = [outFolder ,'db_analysis/'];
    ensureDirExists(analysisDir);

    centroidDirAll = [outFolder,'centroid_analysis/'];
    ensureDirExists(centroidDirAll);

    centroidDir = [centroidDirAll saveID '/'];
    ensureDirExists(centroidDir);
        
    numStatistics = 5;
    centroidFinalStats = cell(numSites,numStatistics);
    

    %returns the mean FRET/CFP ratio in all sites for all
    %(time,concentration) pairts
    numConcentrations = size(baseFolders,1);
    means = zeros(numTimes,numConcentrations);
    stdevs = zeros(numTimes,numConcentrations);
    dim = 540; % number of pixels in an image
    maxNumCells = 100;
    % get the X, Y, height, and width, and standardev for every
    % cell-site-time concentration.
    % should be like 6[conc]*23[t]*4[sites]*100[cell]*6[dataPoints] ~ 300k,
    % 64 bits --> 2.4 MB
    dataPointsPerCell = 8;
    X_Y_H_W_INT_STDEV_N_T = -1 .* ones(numConcentrations,numTimes,...
                        numSites,maxNumCells,dataPointsPerCell);
    % these two are useful for giving debugging output...
    numTotalFiles = (numTimes*numSites*numWavelengths*numConcentrations);
    fileIndex = 1; 
    % start timing for debugging purposes
    for folder=1:numConcentrations
        
        % XXX move this to a utility function. Just trying to get
        % the folder name to save it as...
        folderName = baseFolders{folder};
        lastSlash = find(folderName == '/',2,'last');
        baseName = strrep(folderName(lastSlash(1):end),'/','');
        
        myDir = [analysisDir baseName '/'];
        ensureDirExists(myDir);
    
        bgCorrect = double(ones(dim,dim,numSites));
        tmpFolder = baseFolders{folder};
         % 7 = directory.
        dirExists = (exist(tmpFolder, 'dir') == 7);
        if (~dirExists )
            fprintf('In lab2::allSites, didn''t find folder [%s] \n',tmpFolder);
            continue;
        end
        for times=startTime:startTime+(numTimes-1)
                timeCounter = times-startTime+1;
                %Regex string like: "site 1 wavelength 1 t00.tif"
                % so, in this inner loop, we are looking for
                % (1) at a given concentration
                % (2) at a given time
                % (3) for *all* sites
                % check that all the wavelengths are present at the 
                % given site
                intTemp = zeros(numSites,1);
                stdTemp = zeros(numSites,1);
                for sites=1:numSites
                    fullPath = cell(numWavelengths);
                    for wave=1:numWavelengths
                        % assume thsat the regex has the site, wavelength,
                        % and time formatters...
                        % XXX change to 'callback' function?
                        % XXX change to also give formatting
                        allWavelengthString=sprintf(regexString,sites, ...
                            wave,times);
                        path = [tmpFolder allWavelengthString];
                        files = dir(path);
                        numFiles = size(files,1);
                        % each file represents a different site
                        if (numFiles ~= 1)
                            fprintf('FATAL ERROR: In lab2::allSites, didn''t find exactly one file like [%s] in [%s] \n',...
                                allWavelengthString,tmpFolder);
                            return;
                        end
                        fullPath{wave}  = [tmpFolder files(1).name];
                        fprintf('Processing %s, %.2f/1 complete Time Elapsed: %7.3f s\n',...
                            allWavelengthString,fileIndex/numTotalFiles,toc(initialTime));
                        fileIndex = fileIndex + 1;
                    end
                    invertArr = [false,false,true]; %brightfield should be inverted
                    [ raw,bgCorrected,bw,~,foundNuclei ] = ...
                        singleBgFix(fullPath,blankMatrices,invertArr);
                    % average both channels (for strategic sheep purposes)
                    % XXX averaged removed for now...
                    if (centroids)
                        bgCorrect(:,:,sites) = bgCorrect(:,:,sites) + ...
                            (double(bgCorrected(:,:,1)) + double(bgCorrected(:,:,2)))/(2*numTimes);
                    end
                    % (1) assume the first and second wavelengths are FRET and
                    % CFP respectively
                    % (2) use the pixels found and the background corrected
                    % image...
                    [ratiosByCell,stdevsByCell] = ...
                            getCellRatios(bgCorrected(:,:,1),bgCorrected(:,:,2),foundNuclei);
                    numObj = numel(ratiosByCell);
                    intTemp(sites) = mean(ratiosByCell);
                    stdTemp(sites) = std(ratiosByCell);
                    found_XY_HW = ones(numObj,4) .* -1;
                    for i=1:numObj
                        indices = foundNuclei{i};
                        [xInd,yInd] = ind2sub(size(raw),indices);
                        found_XY_HW(i,1) = round(mean(xInd));
                        found_XY_HW(i,2) = round(mean(yInd));
                        found_XY_HW(i,3) = (max(yInd)-min(yInd))/2;
                        found_XY_HW(i,4) = (max(xInd)-min(xInd))/2;
                    end
                    % XXX use variable names for everything...
                    objArr = ones(numObj,1) .* numObj;
                    timeArr = ones(numObj,1) .* times;
                    X_Y_H_W_INT_STDEV_N_T(folder,timeCounter,sites,1:numObj,1:8) = ...
                    [found_XY_HW, ratiosByCell  stdevsByCell objArr timeArr];
                    fprintf('\tIn %s, found %d objects...\n',tmpFolder,numObj);
                    % save just the last site...
                     if (sites == numSites)
                         %savePath = strcat(myDir, baseName,allWavelengthString);
                         %saveAll(raw,bgCorrected,bw,savePath, ...
                         %       {'FRET','CFP','Bright Field'}, true);
                     end
                end 
             means(timeCounter,folder) = mean(intTemp);
             stdevs(timeCounter,folder) = std(intTemp);
        end
        
        % XXX debugging below for clustering into cells
        % need to do a few things
        % (0) cluster into cells, essentially bin X-Y over all times.
        % (1) remove x-y positions with not enough intensities (half
        % frames?)
        % (2) determine indices of N highest peaks -- these are the cells
        % (3) work backwards, list of indices, track intensities over time
        
        numSitesToPlot = numSites; % XXX change to numSites
        numPlotsPerSite = 3;
        clf, reset(gca), close all;
        fig1 = figure('Position', [0, 0, numPlotsPerSite*dim*2,numSitesToPlot*dim*2],'Visible','Off');
        plotCounter = 1;
        

        saveName = strcat(centroidDir,...
           baseName,'AllSites');
       limitX = [0 , dim];
       limitY = [0 , dim];
        fprintf('Performing Centroid Analysis on %d Sites for %s...\n',numSitesToPlot,baseName);
        
        if (centroids)
        % XXX took out centroids...
            for s=1:numSitesToPlot
                
                % get the stats for this concentration and site for all times
                xRaw =  (X_Y_H_W_INT_STDEV_N_T(folder,:,s,:,1));
                yRaw =  (X_Y_H_W_INT_STDEV_N_T(folder,:,s,:,2));
                heightRaw =  (X_Y_H_W_INT_STDEV_N_T(folder,:,s,:,3));
                widthRaw =  (X_Y_H_W_INT_STDEV_N_T(folder,:,s,:,4));
                intRaw = X_Y_H_W_INT_STDEV_N_T(folder,:,s,:,5);
                % XXX introduce error again later
                %stdRaw = X_Y_H_W_INT_STDEV_N_T(folder,:,s,:,6);
                objNumber = X_Y_H_W_INT_STDEV_N_T(1,:,s,:,7);
                timeRaw = (X_Y_H_W_INT_STDEV_N_T(folder,:,s,:,8));
                % initialize with -1, so have to do some sanitation
                goodIndices = ( (xRaw) >= 0); 
                % http://www.mathworks.com/help/images/image-coordinate-systems.html
                % For pixel indices, the row increases downward, while the
                % column increases to the right. Pixel indices are integer 
                % values, and range from 1 to the length of the row or column.
                % so, we must switch x and y 
                yOverTime = pReshape(xRaw,goodIndices);
                xOverTime = pReshape(yRaw,goodIndices);
                hOverTime = pReshape(heightRaw,goodIndices);
                wOverTime = pReshape(widthRaw,goodIndices);
                intOverTime = pReshape(intRaw,goodIndices);
                timeVals = pReshape(timeRaw,goodIndices);
                % XXX fix standard deviation?
                %stdVals = pReshape(stdRaw,goodIndices);
                %objNominal could be different; only record one per site,
                % since it is the number of nominal cells in a field of view
                objNumber = objNumber(objNumber > 0);
                objNominal = round(mean(objNumber(:)));
                objStd = std((objNumber(:)));
                fprintf('\tPerforming Centroid Analysis on site %d with nominally %d objects...\n', ...
                        objNominal);
                % process the data
                XY = [ xOverTime , yOverTime];
                hwOverTime = [hOverTime,wOverTime];
                dimNominal = median(hwOverTime(:));
                dimStdev = std(hwOverTime(:));
                % cant have more centroids than rows for kmeans
                maxCentroids = max(1,min(objNominal+5*objStd,size(XY,1))); 
                numReplications = 30;
                iters = 200;
                % the distance we will consider centroids to be identical
                % 'dimNominal' gives the median dimensions of a cell, so
                % 2x this value gives the 'box' for two cells, so we are
                % claiming a 'gap' of ~1 cell length, for movment etc
                smoothingDistance = dimNominal+4*dimStdev;
                % a centroid must account for this many frames before it is
                % useful
                minPointsHit = numTimes / 2;
                % fminbnd : bounded by f.
                % use this to minimize the squared sillhouette 
                optSet = optimset('MaxIter',iters,'TolX',0.4);
                bestK = round(fminbnd(@(x) fitMin(x,XY,numReplications),1,maxCentroids,...
                        optSet));
                [~,C] = kmeans(XY,bestK,'Display','off','Replicates',...
                                numReplications*20,'MaxIter',iters*10);
                % search for centroids within 2 * the common distance (ie: 2
                % diameters away) to collapse them
                numCentroids = numel(C)/2;

                idxCentroid = rangesearch(C,C,smoothingDistance);
                toSort = [ C , (1:numCentroids)' , cellfun(@length,idxCentroid)];
                % pick only those centroids overlapping with a specified number
                % of points (ie: frames..)
                sorted = flip(sortrows(toSort,4));
                uniqueCentriodIdx = ones(numCentroids,1) .* -1;
                tmpEle = [];
                eleCount = 0;
                % XXX should be able to make this more efficient.
                % essentially, want to merge the close centroids until
                % we account for everything.
                for i=2:numCentroids
                    closestAndBest = idxCentroid{sorted(i,3)}';
                    newElements = setdiff(closestAndBest,tmpEle);
                    eleCount = eleCount + numel(newElements);
                    if (numel(newElements) > 0)
                        tmpEle = [ tmpEle ; newElements];
                        uniqueCentriodIdx(i) = sorted(i,3);
                    end
                    if (eleCount == numCentroids)
                       break; % got them all. 
                    end
                end
                uniqueCentriodIdx = uniqueCentriodIdx(uniqueCentriodIdx > 0);
                centroids = C(uniqueCentriodIdx,:);          
                % only pick centroids with the given number of points within
                % the distance
                centroidNeighbors = rangesearch(XY,centroids,smoothingDistance);
                tmp = [ centroids , cellfun(@length,centroidNeighbors)];
                % third index is the number of neighbors, 1:2 gives centroid XY
                centroids = tmp(tmp(:,3) > minPointsHit,1:2);
                % find the centroid for each XY point (closest neighbor)
                [IDX_XY_to_Centroid, D] = knnsearch(centroids,XY);
                finalIndices= (D < smoothingDistance);
                IDX_XY_to_Centroid = IDX_XY_to_Centroid(finalIndices);
                % pick out the unique centroids we need.
                % only pick out centroids with more than X neighbors
                IDX_centroid_final = unique(IDX_XY_to_Centroid);
                centroids_final = centroids(IDX_centroid_final,:);
                numCentroids = size(centroids_final,1);
                fprintf('\tFor %s, site %d had %d/%d centroids, complete Time Elapsed: %7.3f\n',...
                        baseName,s, numCentroids,size(centroids,1),toc(initialTime)); 
                XY_final = XY(finalIndices,:);
                % with these next function calls, we are selecting 
                % (1) the 'final indices', where a bright pixel (cell) is 
                %  within the smoothing distance and 
                % (2) the 'IDX_XY_to_Centroid' (ie: mapping bright pixels to
                % their cells...
                % (3) averaging redudant values. We might have a centroid at
                % different (but very close) places at the same time, so we
                % average these out. This is just due to the resolution of the
                % centroid
                centroidRawTime = ...
                    getCentroidNoTime(timeVals,finalIndices,IDX_XY_to_Centroid);
                if (~iscell(centroidRawTime) )
                    fprintf('NONFATAL ERROR: Couldn''t find centroids for %s',baseName);
                   continue; 
                end
                % only pick out the final times...
                % XXX need to combine sites, *badly*...
                centroidFinalTime = cellfun(@(x) unique(x), centroidRawTime,'UniformOutput',false);
                centroidFinalX =  ...
                    getCentroidTimeAvg(XY(:,1),finalIndices,IDX_XY_to_Centroid,centroidRawTime);
                centroidFinalY = ...
                    getCentroidTimeAvg(XY(:,2),finalIndices,IDX_XY_to_Centroid,centroidRawTime);
                centroidFinalInt = ...
                    getCentroidTimeAvg(intOverTime,finalIndices,IDX_XY_to_Centroid,centroidRawTime);
                %centroidFinalStd = ...
                %   getCentroidTimeAvg(stdVals,finalIndices,IDX_XY_to_Centroid,centroidRawTime);
                % save the statistics for each cell for this site.
                centroidFinalStats{s,1} = centroidFinalTime;
                centroidFinalStats{s,2} = centroidFinalX;
                centroidFinalStats{s,3} = centroidFinalY;
                centroidFinalStats{s,4} = centroidFinalInt;
                %centroidFinalStats{s,5} = centroidFinalStd;
                centroidMeanX = cellfun(@mean,centroidFinalX);
                centroidMeanY = cellfun(@mean,centroidFinalY);
                radii_final = getCentroidTimeAvg(mean(hwOverTime,2),...
                    finalIndices,IDX_XY_to_Centroid,centroidRawTime);
                centroidRadii = cellfun(@mean,radii_final);
                fprintf('\tFor %s, site %d, finished centroid aggregation. Complete Time Elapsed: %7.3f\n',...
                        baseName,s,toc(initialTime)); 
                % (1) 'first guess'
                % (2) merge 'nearby' means. (probably overfit)
                % (3) get an updated guess for the means
                % (4) pick out centroids with 'enough' XY points.
                % (5) now we have values for each. 
                marginX = 0.00;
                marginY = 0.15;
                % XXX put this back later
                plotStruct = {};
                pSubplot(numSitesToPlot,numPlotsPerSite,s,plotCounter,marginX,marginY);
                % want a 16-bit representation of the background 'average'
                imToPlot = normMat(bgCorrect(:,:,s));
                subimage(imToPlot);
                set(gca,'YDir','normal');
                title([ baseName ' site ' num2str(s)],plotStruct{:});
                xlim(limitX);
                ylim(limitY);
                % for some reason, plain images display in reverse...
                box on;
                plotCounter = plotCounter + 1;

                pSubplot(numSitesToPlot,numPlotsPerSite,s,plotCounter,marginX,marginY);
                hold all;

                % plot the identified cells
                plot(XY_final(:,1),XY_final(:,2),'b.','MarkerSize',1.5);
                % plot the ones we removed, for clarity
                removed = setdiff(XY,XY_final,'rows');
                plot(removed(:,1),removed(:,2),'r.','MarkerSize',1.5);
                title(['Site ' num2str(s) ', [' ... 
                    num2str(numel(centroids_final)/2) '] centroids'],plotStruct{:});
                xlabel('X Pixel',plotStruct{:});
                ylabel('Y Pixel',plotStruct{:});
                % 1 and 2 are the x-y indices 
                plot(centroids_final(:,1),centroids_final(:,2),'ko','MarkerSize',3,'LineWidth',0.25);
                xlim(limitX);
                ylim(limitY);
                plotCounter = plotCounter + 1;
                box on;
                
                 pSubplot(numSitesToPlot,numPlotsPerSite,s,plotCounter,marginX,marginY);
                 hold all;
                 centroidsCenters =  [ centroidMeanX centroidMeanY ];
                 subimage(imToPlot);
                 colormap(gray);
                 title('Centroids and data',plotStruct{:});
                 viscircles(centroidsCenters,centroidRadii, 'LineStyle','--', ...
                        'EdgeColor','Green','LineWidth',0.20,'DrawBackgroundCircle',false);
                 box on;
                 xlim(limitX);
                 ylim(limitY);
                 plotCounter = 1;
            end
            saveAndCloseFigure(fig1,saveName);
        end
    end
end

function [resulting] = getCentroidTimeAvg(array,validIndices,centroidIndices,...
                        timeRedundant)
    [resulting] = getCentroidNoTime(array,validIndices,centroidIndices);
    for i=1:numel(resulting)
        [~,~,idxToUnique] = unique(timeRedundant{i});
        currentVal = resulting{i};
        resulting{i} = accumarray(idxToUnique,currentVal,[],@mean);
    end
end

function [resulting] = getCentroidNoTime(array,validIndices,centroidIndices)
    array = array(validIndices,:);
    resulting = accumarray(centroidIndices,array,[],@(x) {x} );  
    % get the unique time and indices from unique time to redundant times
        % XXX really just want to average into unique times. Could
        % improve...
        % accumulate values, averaging if we ever find multiple values at
        % a given time.
end
   
function [shaped] = pReshape(matrix,goodIndices)
    shaped = round(matrix(goodIndices));
    shaped = shaped(:);
    shaped = shaped(shaped >= 0);
end

function [concatenated] = catCellCol(cell,column)
    concatenated = cell(:,column);
    concatenated = vertcat(concatenated{:});
end

function [poornessOfFit] = fitMin(numK,data,numReplications)
    [idx] = kmeans(data,round(numK),'Replicates',numReplications, ...
            'EmptyAction','singleton','Display','off');
    [silh4] = silhouette(data,idx);
    % large silhouette values are good for fitting
    % they range from 0->1
    % so the poorness of fit should range from 
    %  0 (best)  to 1(worst)
    poornessOfFit = (1-mean(silh4(:)));
end

function [wellPath]  = getWell(letter,number)
    wellPath = sprintf('well %s%02d',letter,number);
end
