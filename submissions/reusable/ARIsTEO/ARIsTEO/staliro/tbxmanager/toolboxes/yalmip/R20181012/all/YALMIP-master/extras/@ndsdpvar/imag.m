% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = imag(X)
% REAL (overloaded)

X.basis = imag(X.basis);
X.conicinfo = [0 0];
X = clean(X);