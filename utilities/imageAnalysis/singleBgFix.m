function [ raw,bgCorrected,bw,numObj,foundNuclei ] = singleBgFix(filesToFix,blank,invert)
    minObj = 10;
    numFiles = size(filesToFix,1);
    imageSize = 540;
    maxIters = 12;
    % create matrices for the raw, bgCorrected, and binary images.
    raw = uint16(zeros(imageSize,imageSize,numFiles));
    bgCorrected = uint16(zeros(imageSize,imageSize,numFiles));
    % read in the file just once
    for f = 1:numFiles
        currentFile = filesToFix{f};
        % need to invert brightfield...
        disp(currentFile);
        tmp = uint16(imread(currentFile));
        if (invert(f))
            tmp = imcomplement(tmp);
        end
        raw(:,:,f) = (tmp);
        bgCorrected(:,:,f) = correct(raw(:,:,f),blank(:,:,f));
    end
    bw = logical(zeros(imageSize,imageSize,numFiles));
    parfor f = 1:numFiles
        % optimize each channel independently. 
        thisFile = bgCorrected(:,:,f);
        level = graythresh(thisFile(thisFile > 0));
        % XXX this optimized for the lowest standard error across the whole
        % image. This is a bit of a 'waste', since the cells will have a
        % standard deviation, no matter what. At better (slower) method
        % would be to optimize for the standard error of the cell means.
        % This would involve essentially running this whole loop for all
        % three with the bwconncomp. this would be extremely expensive.
        bestThresh = fminbnd(@(x) minimize(x,(thisFile),level),0.25,2.5,...
            optimset('MaxIter',maxIters,'TolX',0.01,'Display','off'));
        bw(:,:,f) = normalizeOne(bgCorrected(:,:,f),bestThresh,level);
    end
    foundObj = prod(bw,3);
    conn = bwconncomp(foundObj);
    numObj = (conn.NumObjects);
    listOfObj = 1:numObj;
    % create a list for all of the nuclei  
    foundNuclei = conn.PixelIdxList(listOfObj);
    if (numObj == 0)
        % XXX break?
       fprintf('In singleBgFix.m, Files like %s, unable to find %2d objects...\n',...
           filesToFix(1,:),minObj);
    end
end

function [fitPoorness] =  minimize(thresh,bgCorrected,level)
    tmp = normalizeOne(bgCorrected,thresh,level);
    % return the 1/(standard error) of the original image
    contributingElements = double(bgCorrected(tmp >0));
    if (numel(contributingElements) == 0)
        fitPoorness = realmax;
    else
        fitPoorness = sqrt(nnz(contributingElements(:)))/std(contributingElements(:));
    end
end

function [correct] = correct(raw,blank)
        bgCorrected= uint16( (double(raw)./double(blank)) *mean(blank(:)) );
        correct = bgCorrected - mean(bgCorrected(:));
end

function [toRet] = normalizeOne(bgCorrect,optCoeff,level)
        toRet = (im2bw(bgCorrect,min(1,level*optCoeff)));
        toRet = bwClose(toRet);
end

function [bw] = bwClose(bwRaw)
        minPixels = 30;
        bw = bwmorph(bwRaw,'close'); 
        bw= uint16(bwareaopen(imfill(bw,'holes'),minPixels));
        bw = logical(bwmorph(bw,'close')); 
end

