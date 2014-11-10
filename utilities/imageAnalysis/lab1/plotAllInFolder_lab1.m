 
function[ECIC50] = plotAllInFolder_lab1(imageFolder,outputFolder,plotTitles,...
                             regexC1,regexC2,conc,EC50,xAxis)
    % --imageFolder: Folder to look for images
    %  outputFolder: where to save the resulting plots 
    %  plotTitles: the titles for the plots, also how they ae saved...
    % --regexC1: all the channel 1 regexes (eg "*w1*.serum.tif" ) for finding
    % this trials images. Can be multi dimensional (eg: {
    % "*w1*.serum.tif","*w1*.noWerum.tif"} )
    % --regexC1: all the channel 1 regexes (eg "*w2*.serum.tif" ) for finding
    % this trials images. Can be multi dimensional (eg: {
    % --"*w2*.serum.tif","*w2*.noWerum.tif"} )    
    % --blankC1: a 'blank' matrix for all the channel ones XXX change to
    % wellbased?
    % -- blankC2 a 'blank' matrix for all the channel twos XXX change to
    % wellbased?
    % -- conc: the concentrations to use..
    % -- EC50: true or false, is this an EC50plot (true) or IC50 (false)
    %  xAxis: what the concentrations mean (e.g. inhibitor or EGF?)
                         
    % assume we always have two channels
    blankMatrixC1 = imread([imageFolder 'empty well_w1.tif']);
    blankMatrixC2 = imread([imageFolder 'empty well_w2.tif']);
    % get all the '.tif' files in that directory
    numTrials = size(regexC1,2);
    % loop through each file, getting the intensity ratio
    % from the two channels
    % get the regex for the inhibited and uninhibited 
    [intensities,stdevs] = ...
        getMatchingFiles_lab1(imageFolder,regexC1,regexC2,...
        blankMatrixC1,blankMatrixC2,conc);
    
    for t=1:numTrials
        ECIC50 = normalizeAndPlot_lab1(conc,intensities(t,:),stdevs(t,:),...
                        [outputFolder plotTitles{t}],plotTitles{t},EC50,xAxis);
        close all;
        clf;
    end 
 
end 
