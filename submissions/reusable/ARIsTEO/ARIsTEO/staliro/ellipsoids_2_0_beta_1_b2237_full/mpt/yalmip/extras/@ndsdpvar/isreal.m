% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function v = isreal(X)
% isreal (overloaded)

% Author Johan L�fberg
% $Id: isreal.m,v 1.2 2006-07-25 12:57:08 joloef Exp $

v = isreal(sdpvar(X));