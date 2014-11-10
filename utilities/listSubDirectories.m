function [list] = listSubDirectories(directory)
    % given a full path, get the (sorted) directires on that path
    d = dir(directory);
    isub = [d(:).isdir]; %# returns logical vector
    list = {d(isub).name}';
    list(ismember(list,{'.','..'})) = [];
end