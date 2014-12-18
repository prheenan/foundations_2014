
function [IC50,EC50Std] = normalizeAndPlot_lab1(egf_pM,ints,stdev,saveLoc,titleStr,IC50,xAxis)
    % normalize the intensities and stdevs to between 0 and 1.
    % stdev scales/shifts like the distribution by Pittman
    %stdev = stdev ./ ( max(ints) - min(ints));
    %ints = (ints - min(ints));
    IC50 = -1;
    EC50Std = -1;
    f = figure('Position', [100, 100, 1500, 1000],'Visible','off');
    hold all;
    errorbar(egf_pM,ints,stdev,'ro');
    % generate a model fit to get the EC50. use log spacing, like the data
    candidates = [egf_pM(egf_pM > 0)];
    minMag = log10(min(candidates)*0.95);
    maxMag = log10(max(egf_pM)+0.5);
    concs = logspace(minMag,maxMag,1000.);   
    power = -1; % the power to raise the a/x in the EC50 model to.
    % if IC50, -1
    % if EC50, 1
    str = 'EC50';
    if (IC50)
        power = 1;
        str = 'IC50';
    end        
    % fit the model against the data
    bottom = min(ints);
    top = max(ints);
    % give the model a normalized version.
    normInts = (ints-bottom)/(top-bottom);
    if (top == bottom || sum(ints(:)) == 0 || numel(ints) == 1)
       fprintf('In normalizeAndPlot for %s, data only had one intensity, or the intensities were the same',...
           titleStr);
       return;
    end
    [beta,ci,RSQ,R] = getModel(egf_pM,normInts,@(a,x) IC50_or_EC50(a,1.0,0,x,power),[0,max(egf_pM)]);
    if (ci < 0)
        toPrint = [ egf_pM' ints' ];
        fprintf('In normalizeAndPlot, couldn''t fit confidence interval for plot... [%s]',titleStr);
        disp(toPrint);
       return;
    end
    yVals = IC50_or_EC50(beta,top,bottom,concs,power);
    plot(concs,yVals+bottom,'b-');
    % make a vertical line at the EC50
    IC50=beta(1);
    EC50Std = getStd( ci, 1, beta );
    % labelling!
    plotStruct = {'FontSize',17};
    % labelling everything
    xlabel(['Concentration of ' xAxis ' [pM]'],plotStruct{:});
    ylabel('FRET/CFP Ratio [arb]',plotStruct{:});
    title(['FRET/CFP vs ' xAxis ' [pM] for ' titleStr], ...
        plotStruct{:},'interpreter','None'); % do not interpret..
    legend('Data', ...
        [str ' Model: ' getPlusMinusStr(IC50,ci,RSQ,[str '[pM]'])], ...
        'Location','southwest');
    % make this a semilog plot (x axis)
    ax = gca;
    grid on;
    grid minor;
    set(ax,'XScale','log');
    % save it to the output file.
    saveFigure(f,saveLoc)
    close(f)
end

function [value]  = IC50_or_EC50(param,maxVal,minVal,x,power)
     fullModel = @(a,top,bottom,x) bottom+(top-bottom) ...
            ./ (1 + (max(a,realmin()) ./ max(x,realmin() )).^power);
     value = fullModel(param,minVal,maxVal,x);
end


