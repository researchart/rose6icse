% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function res = isinterval(Y)
%ISINTERVAL (overloaded)

res = isa(Y.basis,'intval');
