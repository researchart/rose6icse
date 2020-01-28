% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = vertcat(varargin)
% horzcat (overloaded)

x = cat(1,varargin{:});