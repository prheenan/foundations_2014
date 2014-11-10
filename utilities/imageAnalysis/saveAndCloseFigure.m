function [  ] = saveAndCloseFigure(handle,filename)
    saveFigure(handle,filename);
    close(handle);
end
