function [  ] = lab1(  )
    clear,clc, close all;
    % given concentrations
    egf_pM= [0 0.128 0.64 3.2 16 80 400 2000 10000 50000]; %picoMolar
    % for the inhibitor data, the concentrations are messed up in the pdf.
    % start at 5000pM, go down by twos.
    numInhib = 10;
    inhib_pM = zeros(1,numInhib);
    inhib_pM(numInhib) = 5000; % pM
    for i=numInhib-1:-1:2
        inhib_pM(i) = inhib_pM(i+1)/2;
    end
    numPoints = numel(egf_pM);

    % the folder relative to the matlab workspace where the images live
    baseFolder='fall_2014/foundations_phys_7000_code/lab_report_1_egf/';
    % get the blanks for flatfield correction; average them!
    outputFolder = [baseFolder 'output/'];
    % true for EC50
    plotAllInFolder_lab1([baseFolder 'TimePoint_37/'],outputFolder, ...
                    {'10% FBS Serum, Fig 2' 'No Serum, Fig 1'}, ...
                    {'_w1*.serum.tif'  '_w1*.noSerum.tif'}, ...
                    {'_w2*.serum.tif'  '_w2*.noSerum.tif'},egf_pM,true,'EGF');
    
    % false for IC50
    plotAllInFolder_lab1([baseFolder 'TimePoint_72/'],outputFolder, ...
                    {'Whiteout, Inhibited, Fig 3'}, ...
                    {'_w1*.whiteout.tif' }, ...
                    {'_w2*.whiteout.tif'},inhib_pM,false,'Inhibitor');

                
end


