% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = gt(X,Y)
%GT (overloaded)

% Author Johan L�fberg
% $Id: gt.m,v 1.2 2006-07-13 19:40:59 joloef Exp $

if isa(X,'ndsdpvar')
    X = sdpvar(X);
elseif isa(X,'double')
    X = X(:);
end

if isa(Y,'ndsdpvar')
    Y = sdpvar(Y);
elseif isa(Y,'double')
    Y = Y(:);
end

try
    y = constraint(X,'>',Y);
catch
    error(lasterr)
end
