function [str] = getPlusMinusStr(beta,ci,RSQ,labels)
    splitLabels = strsplit(strtrim(labels),',');
    num = length(splitLabels);
    str = [char(10)];
    for i=1:num
        str = [ str splitLabels(i) '=' plusMinusStr(beta,ci,i)];
        if (mod(i,2) == 0)
            str = [ str char(10)]; 
        elseif (i ~= num)
            str = [ str ', ']; % comma separate
        end
    end
    str = [str char(10) 'RSQ=' num2str(RSQ,'%.5g')];
    str = strjoin(str);
end
    
function  [str] = plusMinusStr(beta,ci,index)
    str = [num2str( mean(ci(index,:)),'%.3g') ...
            '+/-' num2str(  getStd( ci, index, beta ) ,'%.2g')];
end

