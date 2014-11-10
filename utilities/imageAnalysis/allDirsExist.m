function [ ret ] = allDirsExist( folders )
%ALLDIRSEXIST Summary of this function goes here
%   Detailed explanation goes here
    ret = true;
    if (~iscell(folders))
        % passed a string, just cell-ify it
        folders = {folders};
    end
    numFolders=  numel(folders);
    for f = 1:numFolders
        tmpFolder = folders{f};
        dirExists = (exist(tmpFolder, 'dir') == 7);
        if (~dirExists )
            fprintf('In lab2::allSites, didn''t find folder [%s] \n',tmpFolder);
            ret = ret && false;
            continue;
        end
    end
end

