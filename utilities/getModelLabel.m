function [str] = getModelLabel(beta,ci,RSQ,labels,overall)
     str = [overall getPlusMinusStr(beta,ci,RSQ,labels)];
end


