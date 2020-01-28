% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = value(X)
% VALUE (overloaded)

X = reshape(value(sdpvar(X)),X.dim);