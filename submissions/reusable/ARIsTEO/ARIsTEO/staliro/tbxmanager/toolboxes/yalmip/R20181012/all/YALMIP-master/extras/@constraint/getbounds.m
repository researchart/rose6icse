% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function LU = getbounds(F,avoidequalitybounds)

if nargin == 1
    LU = getbounds(lmi(F));
else
    LU = getbounds(lmi(F),avoidequalitybounds);
end
