% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function assert(condition,varargin)

if condition, return;
else
  error(varargin{:});
end
