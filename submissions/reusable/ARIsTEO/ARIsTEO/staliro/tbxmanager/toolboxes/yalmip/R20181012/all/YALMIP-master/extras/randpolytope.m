% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [A,b] = randpolytope(n,m)

A = randn(n,m);
b = m*rand(n,1)-A*randn(m,1);