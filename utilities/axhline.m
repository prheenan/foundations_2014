function [ ax ] = axhline( xVals,yVal,str)
%AXHLINE Summary of this function goes here
%   Detailed explanation goes here
    x = [min(xVals) max(xVals)];
    y = ones(1,2) .* yVal;
    if (iscell(str))
        ax = plot(x,y,str{:});
    else
        ax = plot(x,y,str);
    end
end

