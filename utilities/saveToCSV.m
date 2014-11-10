function [] = saveToCSV(fullPath,cellMatrices,headerCell, ...
                        averageValues,headerAverage)
% open the file in write and text mode
fid = fopen(fullPath,'wt');
% get the number of columns (each cell value is a column, different cell)
numCellColumns = numel(cellMatrices);
numCells = numel(cellMatrices{1});
numAverages = size(averageValues,2);
maxRows = max(numCells,size(averageValues,1));
finalString = '';
for m=1:numCells
    for j=1:numCellColumns
        finalString = [finalString,sprintf('Cell%d_%s,',m,headerCell{j})];
    end
end
for j=1:numAverages
    finalString = [finalString,sprintf('%s',headerAverage{j})];
    if (j ~= numAverages)
        finalString = [ finalString ','];
    end
end
finalString = [finalString char(10)];

formatStr = '%.5g';
for i=1:maxRows
   for k=1:numCells
       for p=1:numCellColumns
            currentCellColumn = cellMatrices{p};
            currentCell = currentCellColumn{k};
            if (numel(currentCell) >= i)
                finalString = [finalString,sprintf(formatStr,currentCell(i))];
            end;
            finalString = [finalString,','];
       end
   end
   for l=1:numAverages
        if (size(averageValues,1) >= i)
            currentAvg = averageValues(i,l);
            finalString = [finalString,sprintf(formatStr,currentAvg)];
        end;
        if (l ~= numAverages)
            finalString = [finalString,','];
        end
   end
   finalString = [finalString char(10)]; 
end

fprintf(fid,'%s',finalString);

fclose(fid);

end