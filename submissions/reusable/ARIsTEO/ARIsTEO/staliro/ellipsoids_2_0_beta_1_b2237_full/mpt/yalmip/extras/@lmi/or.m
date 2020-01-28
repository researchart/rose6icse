% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function varargout = or(varargin)
%OR (overloaded)

% Author Johan L�fberg 
% $Id: or.m,v 1.2 2007-08-02 19:33:16 joloef Exp $   

% Models OR using a nonlinear operator definition
varargout{1} = set(yalmip('define','lmior',varargin{:}) == 1);
