% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function N=numel(varargin)
%NUMEL (overloaded)

% Author Johan Löfberg 
% $Id: numel.m,v 1.1 2006-08-10 18:00:21 joloef Exp $   

X = varargin{1};
N = prod(size(X));
