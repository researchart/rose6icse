% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = double(X)
% DOUBLE (overloaded)

X = reshape(double(sdpvar(X)),X.dim);