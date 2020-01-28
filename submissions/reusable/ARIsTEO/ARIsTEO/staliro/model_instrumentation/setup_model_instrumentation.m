% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [  ] = setup_model_instrumentation(varargin)

skip_mex = 0;
for i = 1:nargin
    skip_mex = varargin{1};
end

path_var = pwd;
addpath(path_var);
addpath([path_var,'/src']);
addpath([path_var,'/Switch_intsrumentation']);
addpath([path_var,'/Saturate_intsrument']);
addpath([path_var,'/Matlab_code_intsrumentation']);

cd('mex_DNF')
setup_Boolean2DNF(skip_mex)
cd('..')

end

