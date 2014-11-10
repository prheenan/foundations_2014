
function [intensity,numObj,binaryMatrix,foundNuclei] = getFitAndStats(rawC1,rawC2,threshCoeff)
    % get the ratios for the given 'raw' matrices (which have been
    % background corrected)
        [tmpC1,binaryC1] = normalize(rawC1,threshCoeff);
        [tmpC2,binaryC2] = normalize(rawC2,threshCoeff);
        % multiple the two binary images; need signal in both channels
        binaryMatrix = binaryC1 .* binaryC2;
        % find the cells
        conn = bwconncomp(binaryMatrix);
        numObj = (conn.NumObjects);
        % create a list for all of the nuclei
        listOfObj = 1:numObj;
        if (numObj == 0)
            intensity = 0;
            return
        end
        % mask the pixeled image to the regions of interest...
        pixelC1 = tmpC1 .* binaryMatrix;
        pixelC2 = tmpC2 .* binaryMatrix;
        
        foundNuclei = conn.PixelIdxList(listOfObj);
        intensity = zeros(1,numObj);
        normC2 = nnz(pixelC2);
        normC1 = nnz(pixelC1);
        for i=1:numObj
            % get the mean ratios of each channel
            pixTmpC1 = pixelC1(foundNuclei{i});
            pixTmpC2 = pixelC2(foundNuclei{i});
            C1 = sum(pixTmpC1)/normC1;
            C2 = sum(pixTmpC2)/normC2;
            newRatio = C1/C2;
            intensity(i) = newRatio;
        end
end


function [raw,bw] = normalize(raw,optCoeff)
    % this function attempts to threshold an image
    % to black and white, get rid of 'specs'
    % then attempts to 'fill in' areas that look like
    % continguous blobsm
        % it also multiplies the frame by a given mask
    minPixels = 5;
    bw = raw - mean(raw(:));
    level = graythresh(bw(bw > 0));
    bw = im2bw(bw,min(1,level*optCoeff));
    bw = bwmorph(bw,'close'); 
    bw= uint16(bwareaopen(imfill(bw,'holes'),minPixels));
    % 5 and 10 works pretty well with threshCoeff from 1.75 to 3...
end



