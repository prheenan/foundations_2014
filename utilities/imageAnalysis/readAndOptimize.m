

function [intensity,numObj,bin,foundNuclei] = readAndOptimize(fileC1,fileC2,blank1,blank2,imageFolder)
    % read the files and get the intensities across all nuclei
    % make sure we have at least 3 nuclei per file.
    withBackgroundC1 = imread(fileC1);
    withBackgroundC2 = imread(fileC2);
    backgroundCorrectedC1=uint16( (double(withBackgroundC1)./double(blank1)) *mean(blank1(:)) );
    backgroundCorrectedC2=uint16( (double(withBackgroundC2)./double(blank2)) *mean(blank2(:)) );
    % 9-30-14: tested up to here, looks good. 
    % three works
    thresh = 4.0;
    threshStep = thresh/10;
    numObj = 0;
    while (numObj < 3)
        [intensity,numObj,bin,foundNuclei] = getFitAndStats(backgroundCorrectedC1,backgroundCorrectedC2,thresh);
        thresh = thresh - threshStep;
    end
    
    %[~,fileC1] = strtok(fileC1, imageFolder);
    %[~,fileC2] = strtok(fileC2, imageFolder);
    % comment these back if you want to save all the 'debug'/analysis
    % images
    %saveAll(withBackgroundC1,backgroundCorrectedC1,bin,[imageFolder 'tmp/' fileC1 '_Channel_1'])
    %saveAll(withBackgroundC2,backgroundCorrectedC2,bin,[imageFolder 'tmp/' fileC2 '_Channel_2'])
end     