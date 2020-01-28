% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% find_all_matlab_fcn finds the number of embedded MATLAB function blocks  
% in the Simulink model. The name of the Simulink model should be given as 
% 'modelName' parameter. If the Simulink model does not have any embedded
% MATLAB code, the function prints 0 as 'Number of Matlab blocks:'. If the 
% Simulink model contains any embedded MATLAB code, the function displays 
% the number of MATLAB function blocks and the name of each block.


function [] = find_all_matlab_fcn(modelName)
    bdclose all;
    load_system(modelName);
    handle=find(get_param(gcs,'Object'),'-isa','Stateflow.EMChart');
    sz=length(handle);
    disp('Number of Matlab blocks:');
    disp(sz);
    for i=1:length(handle)
        disp([num2str(i),')Block name is ',handle(i).Name]);
    end
    close_system(modelName);
    return;
end