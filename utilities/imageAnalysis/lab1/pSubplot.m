function [ output_args ] = pSubplot(numRows,numCols,row,column,marginX,marginY)
%PSUBPLOT Summary of this function goes here
%   Detailed explanation goes here
defMargin = 0.025;
if (nargin < 5)
    marginX = defMargin;
end
if (nargin < 6)
    marginY = defMargin;
end
fractionX = 1./numCols;
fractionY = 1./numRows;
x = linspace(0,1-fractionX,numCols);
y = linspace(1-fractionY-marginY,0,numRows);

positionVector1 = [ x(column)+marginX,y(row)+marginY, ...
                    fractionX-marginX, fractionY-marginY];
subplot('Position',positionVector1)

end

