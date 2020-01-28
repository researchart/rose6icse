% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y=horzcat(varargin)
% Horizontal concatenation of Union objects
%
% Note: all Union arrays will be converted to column arrays, regardless
% of their original dimension.

y = vertcat(varargin{:});

end
