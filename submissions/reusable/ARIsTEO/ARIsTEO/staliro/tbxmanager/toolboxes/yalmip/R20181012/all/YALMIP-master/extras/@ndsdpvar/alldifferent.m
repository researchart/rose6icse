% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function t = alldifferent(X)
% alldifferent (overloaded)

t = alldifferent(sdpvar(X));