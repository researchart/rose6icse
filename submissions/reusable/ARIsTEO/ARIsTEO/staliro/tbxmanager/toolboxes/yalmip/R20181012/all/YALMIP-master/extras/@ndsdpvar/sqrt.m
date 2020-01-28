% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = abs(X)
% sqrt (overloaded)

X = reshape(sqrt(reshape(X,prod(X.dim),1)),X.dim);
