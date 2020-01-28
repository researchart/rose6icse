% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [L,M,R] = factors(X)

% Author Johan L�fberg
% $Id: factors.m,v 1.2 2009-10-14 09:10:35 joloef Exp $

L = X.leftfactors;
M = X.midfactors;
R = X.rightfactors;
