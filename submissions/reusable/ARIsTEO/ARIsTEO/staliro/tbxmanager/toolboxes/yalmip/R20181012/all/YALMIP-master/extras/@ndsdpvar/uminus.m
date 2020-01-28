% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = uminus(X)
% UMINUS (overloaded)

X.basis = -X.basis;