% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function basis = lmiBasis(n)
Y = reshape(1:n^2,n,n);
Y = tril(Y);
Y = (Y+Y')-diag(sparse(diag(Y)));
[uu,oo,pp] = unique(Y(:));
basis = sparse(1:n^2,pp+1,1);