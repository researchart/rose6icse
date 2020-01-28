% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = real(X)
% REAL (overloaded)

X.basis = real(X.basis);
X.conicinfo = [0 0];
X = clean(X);