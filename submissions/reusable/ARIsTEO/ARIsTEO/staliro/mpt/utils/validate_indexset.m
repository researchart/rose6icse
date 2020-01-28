% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y=validate_indexset(v)
%
% Check if the argument is a proper index set, otherwise throw an error
%

if isnumeric(v) && isvector(v) && all(isfinite(v)) && all(v>0) && norm(mod(v, 1), Inf)<=0
    y = true;
else
    error('Input argument is a not valid index set.');
end
end
