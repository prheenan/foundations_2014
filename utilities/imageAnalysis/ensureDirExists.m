function [ ] = ensureDirExists( dirToCheck )
%ENSUREDIREXISTS Summary of this function goes here
%   Detailed explanation goes here
    if (~iscell(dirToCheck))
        dirToCheck = {dirToCheck};
    end
    if (~allDirsExist(dirToCheck))
        mkdir(dirToCheck{:});
    end
end

