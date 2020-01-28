% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistancePolytopeEllipsoid
% 
% DESCRIPTION:
% Computes the distance between an ellipsoid
%       (x-x0)'Q(x-x0) <= r
% and a polytope
%       C x <= d
%
% INTERFACE:
%   dist = DistancePolytopeEllipsoid(c,d,x0,Q,r)
%
% INPUTS:
%   - x0: the center of the ellipsoid
%   - Q,r: ellipsoid parameters
%   - C: the array where each row contains one vector c_i
%   - d: the vector where each row contains one scalar d_i
%
% OUTPUTS:
%   - dist: the minimum distance between the polytope and the ellipsoid
%
% DEPENDENCIES:
%   This function requires the matlab toolbox CVX.
%
% See also: DistEllipsoidFromPlane, DistFromEll, DistFromHPandEll

% Georgios Fainekos - GRASP Lab - Last update 2006.09.09

function cvx_optval = DistancePolytopeEllipsoid(cc,dd,e0,MM,rr)
[noc,nos,nod] = size(cc);
if nod~=1 
    error('DistancePolytopeEllipsoid: The code right now does not support unions of polytopes in the guard sets');
end
% solve a quadratic program
cvx_quiet(1);
cvx_begin
    variables x1(nos) x2(nos)
    minimize norm(x1-x2)
    cc*x1<=dd
    (x2-e0)'*MM*(x2-e0)<=rr
cvx_end
