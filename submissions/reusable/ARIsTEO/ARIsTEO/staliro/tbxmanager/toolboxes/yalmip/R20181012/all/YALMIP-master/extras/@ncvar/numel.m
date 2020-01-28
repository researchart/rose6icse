% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function N=numel(varargin)
%NUMEL (overloaded)

X = varargin{1};
N = prod(size(X));
