% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function t = alldifferent(X)
% alldifferent (overloaded)

% Author Johan L�fberg
% $Id: alldifferent.m,v 1.1 2006-05-17 15:15:25 joloef Exp $

t = alldifferent(sdpvar(X));