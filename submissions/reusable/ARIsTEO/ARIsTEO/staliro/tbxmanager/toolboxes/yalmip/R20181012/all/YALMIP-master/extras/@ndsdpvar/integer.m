% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = integer(x)
% integer (overloaded)

x = sdpvar(x);
x = binary(x);