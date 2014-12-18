function [  ] = saveAndCloseFigure(handle,filename,out)
    saveFigure(handle,filename,out);
    close(handle);
end
