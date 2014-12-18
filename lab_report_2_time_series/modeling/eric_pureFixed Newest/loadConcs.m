function [conc,params,initial_conditions,conc2,ERKt] = loadConcs()
    % if the file doesn't exist, re-run
    fileNameInhibs = 'Inhib Values.xlsx';
    conc(1,:)=xlsread(fileNameInhibs,'0hr','B2:K2');
    conc(2,:)=xlsread(fileNameInhibs,'0hr','M2:V2');
    conc(3,:)=xlsread(fileNameInhibs,'0hr','X2:AG2');
    conc(4,:)=xlsread(fileNameInhibs,'0hr','AI2:AR2');
    conc(5,:)=xlsread(fileNameInhibs,'0hr','AT2:BC2');
    conc(6,:)=xlsread(fileNameInhibs,'0hr','BE2:BN2');

    %Load model values
    fileNameParams = 'simplified values.xlsx';
    sheetParams = 'Values3';
    params=xlsread(fileNameParams,sheetParams,'I2:I57');
    initial_conditions=xlsread(fileNameParams,sheetParams,'E2:E26');

    conc2=conc(:,1);
    ERKt=initial_conditions(11)+initial_conditions(12);
end