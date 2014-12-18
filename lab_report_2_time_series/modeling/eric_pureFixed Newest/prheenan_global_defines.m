outputDir = ['/Users/patrickheenan/Documents/MATLAB/fall_2014/' ...
             'foundations_phys_7000_code/lab_report_2_time_series/modelout/'];

ensureDirExists(outputDir);
fMinDir = [outputDir 'fmin/'];
timeCourseDir = [outputDir 'timeCourse/'];
ensureDirExists(fMinDir);
ensureDirExists(timeCourseDir);

plotStruct = {'FontSize',16};

fminFileSave = 'fmin.mat';
timeCourse3FileSave = 'time3Save';
timeCourseFileSave = 'timeSave.mat';