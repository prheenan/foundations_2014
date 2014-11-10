function [ blanks ] = getBlanks( imageFolder,intendedPaths,listedDirs,...
                        numTimes, numWavelengths)
    numBlankFolders = numel(intendedPaths);
    % make a huge array for all of the blanks
    blanks = uint32(zeros(540,540,numWavelengths,numTimes));
    numFilesPerBlank = uint32(zeros(numWavelengths,numTimes));
    % XXX gruff..
    regexStr = 'site * wavelength %d t%02d.tif';
    for i=1:numBlankFolders
        well = intendedPaths{i};
        if (ismember(well,listedDirs))
            path = [imageFolder well '/'];
            files = dir(path);
            for t=1:numTimes
                for wave=1:numWavelengths
                    allWavelengthString=sprintf(regexStr,wave,t);
                    regexPath = [path allWavelengthString];
                    files = dir(regexPath);
                    numFiles = size(files,1);
                    numFilesPerBlank(wave,t) = numFilesPerBlank(wave,t) + numFiles;
                    if (numFiles > 0)
                       for f=1:numFiles
                            currentFiles = [path (files(1).name)];
                            blanks(:,:,wave,t) = blanks(:,:,wave,t) + ...
                                uint32(imread(currentFiles));
                       end
                    else
                        fprintf('In getBlanks, Couldn''t find file like %s in %s\n',allWavelengthString,path);
                    end
                end
            end
        else
            fprintf('In getBlanks, Couldn''t find folder like %s in %s\n',well,imageFolder)
        end  
    end
    % XXX vectorize this
    for w=1:numWavelengths
        for t=1:numTimes
            blanks(:,:,w,t) = blanks(:,:,w,t) ./ numFilesPerBlank(w,t);
        end
    end
    blanks = uint16(blanks);
end

