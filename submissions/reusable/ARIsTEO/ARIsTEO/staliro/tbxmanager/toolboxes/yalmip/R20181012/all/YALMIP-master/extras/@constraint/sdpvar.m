% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = sdpvar(X)
% Internal class for constraint list

F = sdpvar(lmi(X));
