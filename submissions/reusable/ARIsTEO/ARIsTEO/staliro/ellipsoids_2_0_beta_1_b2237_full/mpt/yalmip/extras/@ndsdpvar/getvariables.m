% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function v = getvariables(X)
% getvariables (overloaded)

% Author Johan Löfberg
% $Id: getvariables.m,v 1.2 2006-07-13 19:40:59 joloef Exp $

v = getvariables(sdpvar(X));
