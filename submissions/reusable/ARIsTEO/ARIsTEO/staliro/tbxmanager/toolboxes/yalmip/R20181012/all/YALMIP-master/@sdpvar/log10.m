% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function varargout = log10(varargin)
%log10 (overloaded)

varargout{1} = log(varargin{1})/log(10);