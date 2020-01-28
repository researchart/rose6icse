% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistFromEll 
% 
% DESCRIPTION:
% Computes the distance between a point x and an ellipsoid
%       (x-x0)'Q(x-x0) <= r
% 
% INTERFACE:
%   dist = DistFromEll(x0,x0,Q,r)
%
% INPUTS:
%   - x: the current point (a column vector)
%   - x0: the center of the ellipsoid
%   - Q,r: ellipsoid parameters
%
% OUTPUTS:
%   - dist: the minimum distance of x from the ellipsoid
%
% DEPENDENCIES:
%   This function requires the matlab toolbox CVX.
%
% See also: DistancePolytopeEllipsoid, DistFromHPandEll

% Georgios Fainekos - GRASP Lab - Last update 2006.09.09

function dist = DistFromEll(x0,e0,MM,rr)
nos = length(x0); 
cvx_quiet(1); 
cvx_begin SDP 
variables lambda tau
maximize tau
lambda >= 0
Q = eye(nos)-lambda*MM;
R = lambda*MM*e0-x0;
P = x0'*x0+lambda*(rr-e0'*MM*e0);
[Q R; R' P-tau]>=0
cvx_end 
dist = sqrt(tau);

