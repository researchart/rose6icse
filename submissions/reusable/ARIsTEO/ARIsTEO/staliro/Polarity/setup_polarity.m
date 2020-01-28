% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% setup_polarity would automatically compile all the files needed for
% running polarity

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2013.01.27


function setup_polarity(varargin)

skip_mex = 0;
if nargin == 1
    skip_mex = varargin{1};
end

path_var=pwd;
addpath(path_var);

if ~skip_mex
    mex mx_polarity.c cache.c lex.c parse.c rewrt.c polarity.c
end

disp('***************************************************************************')
disp('You are all set to use Polarity!')
disp('***************************************************************************')

