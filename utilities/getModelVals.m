function [ vals ] = getModelVals( x,model,beta )
    % assume model is an anonymous function on beta
    vals = model(beta,x)
end

