% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = integer(x)
% integer (overloaded)

% Author Johan L�fberg
% $Id: integer.m,v 1.1 2006-05-17 12:03:46 joloef Exp $

x = sdpvar(x);
x = binary(x);