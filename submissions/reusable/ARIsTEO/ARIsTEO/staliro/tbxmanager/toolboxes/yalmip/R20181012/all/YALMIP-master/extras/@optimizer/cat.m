% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = cat(varargin)

if nargin == 1
    sys = varargin{1};
    return
end

y = horzcat(varargin{:});