function [  ] = writeMatrix( fileName,matrix,headers,delimStr,precisionStr)
    numCols = size(matrix,2);
    singleRow = [1,numCols];
    if (nargin < 4)
        delimStr = ',';
        fileName = [fileName '.csv'];
    end
    if (nargin < 3)
        headers = repmat({delimStr},singleRow);
        headers{1} = ['Default Header for ' fileName];
    end
    if (nargin < 5)
       precisionStr = '%15.12f';
    end
    fileID = fopen(fileName,'w');
    for i=1:numCols
        fprintf(fileID,'%s%s',headers{i},delimStr);
    end
    fprintf(fileID,'\n');
    fclose(fileID);
    % append to the file
    dlmwrite(fileName,matrix,'delimiter',delimStr,'precision',precisionStr,'-append');

end

