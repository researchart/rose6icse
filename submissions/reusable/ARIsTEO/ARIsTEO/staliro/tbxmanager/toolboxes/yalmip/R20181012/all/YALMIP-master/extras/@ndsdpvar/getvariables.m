% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function v = getvariables(X)
% getvariables (overloaded)

v = getvariables(sdpvar(X));
