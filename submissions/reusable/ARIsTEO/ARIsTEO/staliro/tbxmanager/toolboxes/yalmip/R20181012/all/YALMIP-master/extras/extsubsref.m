% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function z=extsubsref(x,i,j);

if nargin < 3
    z = x(i);
else
    z=x(i,j);
end
