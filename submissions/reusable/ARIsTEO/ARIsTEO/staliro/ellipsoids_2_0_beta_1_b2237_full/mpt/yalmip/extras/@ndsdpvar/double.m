% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = double(X)
% DOUBLE (overloaded)

% Author Johan L�fberg
% $Id: double.m,v 1.2 2006-07-13 19:40:59 joloef Exp $

X = reshape(double(sdpvar(X)),X.dim);