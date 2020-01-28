% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Constraint = dd(X)

if issymmetric(X)
    W = X-diag(diag(X));
    Z = sdpvar(length(X));
    Constraint = [-Z(:) <= W(:) <= Z(:), diag(X) >= sum(Z,2)];
else
    error('dd requires a symmetric argument.');
end