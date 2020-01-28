% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = replace(F,x,w,expand)
% Internal class for constraint list

F = lmi(F);
if nargin ==3
    F = replace(F,x,w);
else
    F = replace(F,x,w,expand);
end

