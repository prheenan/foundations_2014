function [] = lab2_wrapper(debugging,cluster,centroids)

addpath(genpath('../utilities/'));

if debugging
    numTimes={15}; 
    wells = {'G'};
    wellNumbers = 5:6; 
else
    numTimes={23 , 20}; 
    wells = {'B' 'C' 'D' 'E' 'F' 'G'};  
    wellNumbers = 2:11;
end
% path where to look for images / put output
baseFolder = {};
% path, where the images are
imageFolder = {};
% output path, where to place the images. should *not* end with a slash,
% since we increment it each time.
outputFolder = {};

if (cluster)
    baseFolder = {'../../' , '../../' };
    base = baseFolder{1};
    imageFolder= { [base 'Inhibitor Timecourses/0hr/'],[base 'Inhibitor Timecourses/6hr/']};
    outputFolder = { [base 'output0hr'] , [base 'output6hr'] };
else    
    baseFolder = {'fall_2014/foundations_phys_7000_code/lab_report_2_time_series/'};
    imageFolder= { [baseFolder{1} 'test images/'] };
    outputFolder =  { [baseFolder{1} 'output'] };
end  

    % run all the wells we want.
    for i=1:numel(imageFolder)
        dirTmp = outputFolder{i};
        
        count = 1;
        while (allDirsExist(dirTmp))
           dirTmp = [outputFolder{i} num2str(count,'%3d')];
           count = count + 1;
        end
        dirTmp = [dirTmp '/']; % add the trailing paren
        ensureDirExists(dirTmp);
        
        % post: found an output directory.
        lab2_func(baseFolder{i},imageFolder{i},dirTmp,numTimes{i},wellNumbers,wells,centroids);
    end
end
