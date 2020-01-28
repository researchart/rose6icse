% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  F = projection(F,x,varargin)
% projection  Projects polytopic set object (Requires the Multi-parametric Toolbox).
%
% Fproj     = projection(F,x)
%
% F      : Polytopic set object
% x      : Variables to project on
% method : See HELP PROJECTION

F = projection(lmi(F),x,varargin{:});
