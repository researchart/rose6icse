% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% setup_dp_t_taliro would automatically compile all the files needed for
% running dp_t_taliro

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2018.02.16


function setup_dp_t_taliro(varargin)

skip_mex = 0;
if nargin == 1
    skip_mex = varargin{1};
end

path_var=pwd;
addpath(path_var);

if ~skip_mex
    mex -compatibleArrayDims mx_dp_t_taliro.c cache.c distances.c lex.c DynamicProgramming.c parse.c rewrt.c
end

disp('***************************************************************************')
disp('You are all set to use DP_t_TaLiRo!')
disp('Type "help dp_t_taliro" to get a detailed description of using the tool.')
disp('***************************************************************************')

