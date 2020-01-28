% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function d = polydim(P)
%
% d = polydim(P)
%
% Compute representation dimension of polytope P
%
d = size(P,2)-1;
