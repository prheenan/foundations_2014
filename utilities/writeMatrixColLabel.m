function [  ] = writeMatrixColLabel( fileName,matrix,headers,firstCol,firstColLabel)
    % this function adds a label column to the beginning. In theory, you
    % could have multiple labels.
    numDataLabels = numel(headers);
    if (iscell(firstColLabel))
        labelStr = firstColLabel{:};
    else
        labelStr = firstColLabel;
    end
    labels = {labelStr headers{:}};
    firstCol = reshape(firstCol,numel(firstCol),1);
    writeMatrix(fileName,[firstCol matrix],labels);
end

