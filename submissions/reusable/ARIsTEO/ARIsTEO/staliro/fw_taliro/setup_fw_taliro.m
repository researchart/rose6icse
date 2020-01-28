% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function setup_fw_taliro(varargin)

path_var=pwd;
addpath(path_var);

skip_mex = 0;
if nargin == 1
    skip_mex = varargin{1};
end

if ~skip_mex
    mex  mx_fw_taliro.c cache.c distances.c lex.c mtlmonitor.c parse.c rewrt.c
end


disp('***************************************************************************')
disp('You are all set to use FW-TaLiRo!')
disp('Type "help fw_taliro" to get a detailed description of using the tool.')
disp('***************************************************************************')

