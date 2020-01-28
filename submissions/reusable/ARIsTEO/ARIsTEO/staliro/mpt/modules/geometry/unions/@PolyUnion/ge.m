% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function status = ge(U1, U2)
% tests whether U1 is a (non-strict) superset of U2

status = (U2 <= U1);

end
