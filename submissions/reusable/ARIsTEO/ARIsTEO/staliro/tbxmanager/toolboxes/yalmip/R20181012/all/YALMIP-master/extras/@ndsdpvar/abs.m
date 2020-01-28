% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = abs(X)
%ABS (overloaded)

X = reshape(abs(reshape(X,prod(X.dim),1)),X.dim);
