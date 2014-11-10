function [ output_args ] = axvline( xVal,yVal,str )
%AXVLINE Summary of this function goes here
%   Detailed explanation goes here
    plot(xVal.*ones(1,2),2.*[min(yVal) max(yVal)],str);
end

