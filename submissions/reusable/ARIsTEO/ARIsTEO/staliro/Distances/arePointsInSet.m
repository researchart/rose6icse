% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION arePointsInSet
% 
% DESCRIPTION: 
%   Find if a array of vectors x is inside a convex polyhedron defined 
%   as A*x<=b
%
% INTERFACE: 
%   inSet = arePointsInSet(x,A,b)
%
% INPUTS:
%   - x: the set of points. Each column represents a different vector. The
%        number of rows in x must match the number of columns in A
%   - A: the array where each row contains one vector a_i
%   - b: the vector where each row contains one scalar b_i
%
% OUTPUTS:
%   - inSet: 1 if a point is in the set, 0 otherwise
%
% See also: isPointInSet, DistProjFromPlane, ProjOnPlane, DistFromPolyhedra
%

% Georgios Fainekos - GRASP Lab - Last update 2006.08.07

function inSet = arePointsInSet(x,A,b)
[noc,nos,nod] = size(A);
if nod~=1  
    error('arePointsInSet: The set must be convex.');
end
[ns,nv] = size(x);
if ns~=nos
    error('arePointsInSet: The dimension of the vector and dimension of the constraints do not match.');
end
inSet = min(A*x<=repmat(b,1,nv));
