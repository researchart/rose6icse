% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = sdpvar(X)
% Internal class for constraint list

% Author Johan L�fberg
% $Id: sdpvar.m,v 1.1 2004-06-17 08:40:03 johanl Exp $


F = X.Evaluated{1};
