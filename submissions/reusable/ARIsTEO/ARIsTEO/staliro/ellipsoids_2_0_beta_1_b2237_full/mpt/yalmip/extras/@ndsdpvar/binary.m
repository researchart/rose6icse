% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = binary(x)
% binary (overloaded)

% Author Johan L�fberg
% $Id: binary.m,v 1.2 2006-07-13 19:40:58 joloef Exp $

x = binary(sdpvar(x));