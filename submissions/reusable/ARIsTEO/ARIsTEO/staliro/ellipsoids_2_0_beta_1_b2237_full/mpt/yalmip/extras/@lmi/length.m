% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function varargout=size(varargin)

% Author Johan L�fberg 
% $Id: length.m,v 1.2 2004-07-19 13:54:36 johanl Exp $   

F = varargin{1};
varargout{1} = size(F.clauses,2);

