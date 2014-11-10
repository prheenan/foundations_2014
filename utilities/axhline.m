function [  ] = axhline( xVals,yVal,str)
%AXHLINE Summary of this function goes here
%   Detailed explanation goes here
    plot([min(xVals) max(xVals)],ones(1,2) .* yVal,str);
end

