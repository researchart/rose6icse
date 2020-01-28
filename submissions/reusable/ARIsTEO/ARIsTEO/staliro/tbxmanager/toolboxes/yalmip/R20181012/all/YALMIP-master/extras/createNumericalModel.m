% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function p = createNumericalModel(varargin);

p = emptyNumericalModel;

if nargin >= 1
    p.F_struc = varargin{1};
end
if nargin >= 2
    p.K = varargin{2};
end
