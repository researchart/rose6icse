% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function res = isinterval(Y)
%ISINTERVAL (overloaded)

% Author Johan L�fberg 
% $Id: isinterval.m,v 1.1 2006-12-14 13:20:36 joloef Exp $   

res = isa(Y.basis,'intval');
