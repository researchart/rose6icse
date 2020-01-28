% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistFromHPandEll
% 
% DESCRIPTION:
% Compute the distance of a point from a set defined by a set of 
% hyperplanes (polytope C x <= d) and an ellipsoid ((x-x0)'Q(x-x0) <= r)
% which adds concave constraints.
%
% INTERFACE:
%   dist = DistFromHPandEll(x,C,d,x0,Q,r)
%
% INPUTS:
%   - x: the current point
%   - C: the array where each row contains one vector c_i
%   - d: the vector where each row contains one scalar d_i
%   - x0: the center of the ellipsoid
%   - Q,r: ellipsoid parameters
%
% OUTPUTS:
%   - dist: the minimum distance
%
% DEPENDENCIES:
%   This function requires the matlab toolbox CVX.
%
% See also: DistEllipsoidFromPlane, DistFromEll, DistancePolytopeEllipsoid

% DISCRIPTION:
% NOTE: In general it computes an underapproximation of the distance
% Check if strong duality holds, most probably not

function dist = DistFromHPandEll(x0,cc,dd,e0,MM,rr)
[noc,nos,nog] = size(cc); 
cvx_quiet(1); 
cvx_begin SDP
variables lambda tau mi(noc,1)
maximize tau
lambda >= 0
mi >= 0
Q = eye(nos)-lambda*MM;
R = lambda*MM*e0-x0+1/2*cc'*mi;
P = x0'*x0+lambda*(rr-e0'*MM*e0)-mi'*dd;
Q>=0
[Q R; R' P-tau]>=0
cvx_end 
dist = sqrt(tau);

