% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function v = isreal(X)
% isreal (overloaded)

v = isreal(sdpvar(X));