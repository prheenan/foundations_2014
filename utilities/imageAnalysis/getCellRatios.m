function [ratiosByCell,stdevsByCell] = getCellRatios(numer,denom,indices)
    numCells = numel(indices);
    ratiosByCell = ones(numCells,1) .* -1;
    stdevsByCell = ones(numCells,1) .* -1;
    for i=1:numCells
        slice = indices{i};
        cellRatio = double(numer(slice)) ./ double(denom(slice));
        cellRatio = cellRatio(~isnan(cellRatio));
        cellRatio = cellRatio(~isinf(cellRatio));
        if (numel(cellRatio) > 0)
            ratiosByCell(i) = mean(cellRatio);
            stdevsByCell(i) = std(cellRatio);
        end
    end
    goodIndices = (ratiosByCell > 0);
    ratiosByCell = ratiosByCell(goodIndices);
    stdevsByCell = stdevsByCell(goodIndices);
end