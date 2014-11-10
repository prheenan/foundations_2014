function [ std ] = getStd( ci, index, beta )
    std = abs(ci(index,1) - beta(index));
end

