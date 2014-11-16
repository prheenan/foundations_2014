function [ steadyStateMean, steadyStateStd, steadyStateArray, slice ] = ... 
        getSteadyState( array )
    % one inhibitor per row
    numInhib = size(array,1);
    numTimes = size(array,2);
    numPoints = round(numTimes/2);
    slice = (numPoints:numTimes);
    steadyStateArray = array(:,slice);
    % sum along the rows (second dimension -- sum all the columns in the row)
    steadyStateMean = mean(steadyStateArray,2)'; 
    % flag is zero
    steadyStateStd  = std(steadyStateArray,0,2)';
end

