% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function assign(x,y)
% assign (overloaded)

% Author Johan L�fberg
% $Id: assign.m,v 1.1 2006-07-13 19:40:59 joloef Exp $

assign(sdpvar(x),y(:));