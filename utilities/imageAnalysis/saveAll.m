
function [] = saveAll(raw,backgroundCorrected,binary,name,labels,composite)
   [dimX,dimY] = size(binary(:,:,1));
    %% 
    numMatrices = 5;
    numOriginal = size(raw,3);
    numSubplots = (numOriginal) *numMatrices;
    if (composite)
        % XXX prolly need to add back in...
        numSubplots = numSubplots + numMatrices;
    end
    numPerRow = numMatrices;
    numRows = numSubplots/numPerRow;
    
    fig1 = figure('Position', [0, 0, dimX*numPerRow,dimY*numRows],'Visible','off');
    titleSuffix = {
        ' Raw',
        ' PC Raw',
        ' PC BG Corr',
        ' PC Binary',
        ' Selected',
    };
    if (composite)
        compositeAdd = zeros(dimX,dimY,3,numMatrices);
    end;
    for j=1:numOriginal
        colorZero = double(zeros(dimX,dimY,3));
        rawImg = raw(:,:,j);
        bgCorr=backgroundCorrected(:,:,j);
        bin =uint16(binary(:,:,j));
        selected = uint16(bin) .* (bgCorr);
        matrices = {rawImg, rawImg, ...
            (bgCorr),logical(bin),(selected) };
        for i=1:numPerRow
            pSubplot(numRows,numPerRow,j,i);
            rawMat = matrices{i};
            mat = normMat(rawMat);
            colorZero(:,:,j) = mat;
            if (i > 1 && composite && i < numPerRow)
                % if not the first (raw) matrix or last, and composite, show as
                % psuedo-color
                if (i < numPerRow)
                    image(colorZero);                    
                end
            else
                % just show as normal color if raw, or not composite
                subimage(normMat(mat));
            end
            axis image off;
            title(strcat(labels(j) , titleSuffix(i)));
            if (composite)
                % save this matrix for making the composite image later
                compositeAdd(:,:,j,i) = mat;
            end
        end
    end
    
    if (composite)
        %'first' will just be selected cells.
        pSubplot(numRows,numPerRow,numRows,1);
        RGB = compositeAdd(:,:,:,4); % display the selected cells
        toShow = logical(prod(binary,3));
        subimage(toShow);
        axis image off;
        title('Selected Cells');
        for i=2:numPerRow
            pSubplot(numRows,numPerRow,numRows,i);
            RGB = compositeAdd(:,:,:,i);
            image(RGB);
            title(['Composite' titleSuffix{i}]);
            axis image off;
        end
    end
    % add up all for composite, save as uncompressed tiff: http://www.mathworks.com/help/matlab/ref/print.html    
   	saveAndCloseFigure(fig1,name);
end


