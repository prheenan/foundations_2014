function [  ] = saveFigure( handle,filename,ending )
    % saveas supports only a few things over ssh (nodisplay):
        %   http://www.mathworks.com/help/matlab/ref/saveas.html
    % saveas uses print: http://www.mathworks.com/help/matlab/ref/print.html
        % The formats which you cannot generate in nodisplay mode on UNIX and Mac platforms are:
            %   bitmap (-dbitmap) ? Windows bitmap file
            %   bmp (-dbmp...) ? Monochrome and color bitmaps
            %   hdf (-dhdf) ? Hierarchical Data Format
            %   svg (-dsvg) ? Scalable Vector Graphics file
            %   tiffn (-dtiffn) ? TIFF image file, no compression
    % according to this: http://stackoverflow.com/questions/24803383/save-high-resolution-figures-with-parfor-in-matlab
    % the EPS is pest because of black magic in parallelization
    if (nargin < 3)
        saveStr = '-dpsc';
        saveName = [filename '.eps'];
    else
        % assume PNG for now...
        saveStr = '-dpng';
        saveName = [filename '.png'];
    end
    print(handle,saveStr,'-r250',saveName);

end

