% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function varargout=length(varargin)

F = varargin{1};
varargout{1} = length(F.LMIid);
