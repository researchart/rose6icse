% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = uminus(X)
% UMINUS (overloaded)

% Author Johan L�fberg
% $Id: uminus.m,v 1.2 2006-07-13 19:40:59 joloef Exp $

X.basis = -X.basis;