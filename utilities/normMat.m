function [ normed ] = normMat( mat )
%NORMMAT Summary of this function goes here
%   Detailed explanation goes here
    minV = double(min(mat(:)));
    maxV = double(max(mat(:)));
    normed = (double(mat) - minV) ./ (maxV - minV);

end

