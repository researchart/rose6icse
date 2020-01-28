% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = horzcat(varargin)
% horzcat (overloaded)

x = cat(2,varargin{:});