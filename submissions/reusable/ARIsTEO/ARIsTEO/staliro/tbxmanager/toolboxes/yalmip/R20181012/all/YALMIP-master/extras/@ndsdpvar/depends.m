% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function v = depends(X)
% depends (overloaded)

v = depends(sdpvar(X));