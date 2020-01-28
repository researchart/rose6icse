% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% setup_tp_taliro would automatically compile all the files needed for
% running tp-taliro

% (C) 2017 by Georgios Fainekos (fainekos@asu.edu)


function setup_tp_taliro(varargin)

skip_mex = 0;
if nargin == 1
    skip_mex = varargin{1};
end

path_var=pwd;
addpath(path_var);

if ~skip_mex
    mex -compatibleArrayDims mx_tp_taliro.c cache.c distances.c lex.c DP.c parse.c rewrt.c
end

disp('***************************************************************************')
disp('You are all set to use TP-TaLiRo!')
disp('Type "help tp_taliro" to get a detailed description of using the tool.')
disp('***************************************************************************')

