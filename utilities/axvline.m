function [ ax  ] = axvline( xVal,yVal,str )
%AXVLINE Summary of this function goes here
%   Detailed explanation goes here
    x = xVal.*ones(1,2);
    y = [min(yVal) max(yVal)];
    if (iscell(str))
        ax = plot(x,y,str{:});
    else
        ax = plot(x,y,str);
    end
end

