% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function v = depends(X)
% depends (overloaded)

% Author Johan L�fberg
% $Id: depends.m,v 1.2 2006-07-13 19:40:59 joloef Exp $

v = depends(sdpvar(X));