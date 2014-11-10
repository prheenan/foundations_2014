function [beta,ci,RSQ,R] = getModel(x,y,model,init)
    optimize = @(paramValues) (y - model(paramValues,x));
    if (numel(init) == 1)
        [beta,~,R,~,~,~,J] =lsqnonlin(optimize,init(1));
    else        
        [beta,~,R,~,~,~,J] =lsqnonlin(optimize,mean(init),init(1),init(2));
    end
    ci = -1;
    RSQ = 0;
    if (numel(beta) == 0  || numel(R) == 0 || numel(J) == 0)
        fprintf('In getModel, couldn''t fit Model...\n');
       return;
    end

    ci = nlparci(beta,R,'jacobian',J);
    C = corrcoef(model(beta,x),y ); 
    RSQ = C(1,2)^2;
end