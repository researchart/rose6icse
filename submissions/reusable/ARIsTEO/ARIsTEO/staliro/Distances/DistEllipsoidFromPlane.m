% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistEllipsoidFromPlane 
% 
% DESCRIPTION:
% Computes the distance between an ellipsoid
%       (x-x0)'Q(x-x0) <= r
% and the part of the hyperplane
%       c x <= d
% such that the vecotr field dx/dt = Ax+b is outgoing on the hyperplane.
% That is it computes the distance between the sets
%       {x in R^n | (x-x0)'Q(x-x0) <= r}
% and
%       {x in R^n | c(Ax+b)<=d} 
% 
% INTERFACE:
%   dist = DistEllipsoidFromPlane(x0,Q,r,c,d,A,b)
%   If the dynamics A,b of the system are not provided, then they are
%   ignored.
%
% INPUTS:
%   - x0: the center of the ellipsoid
%   - Q,r: ellipsoid parameters
%   - c,d: a hyperplane or polyhedral set, i.e. c*x<=d
%     Comments:
%     1. Each row of c represents a different constraint on x.
%     2. The columns of c must match the dimension of x.
%     3. The input might be a union of hyperplanes of polyhedral sets if no
%        system dynamics are given as input. In this case, c is a 
%        3 dimensional array, i.e., each hyperplane or polyhedral set is
%        defined as c(:,:,i)*x <= d(:,i)
%     4. If system dynamics are provided as input, then only a union of
%        hyperplanes is allowed.
%   - A,b: the matrix and the vector that model the linear system dynamics 
%
% OUTPUTS:
%   - dist: the minimum distance between the hyperplane/polytope and the
%     ellipsoid
%
% DEPENDENCIES:
%   This function requires the matlab toolbox CVX.
%
% See also: DistancePolytopeEllipsoid, DistFromEll, DistFromHPandEll

% Georgios Fainekos - GRASP Lab - Last update 2006.09.09

function dist = DistEllipsoidFromPlane(x0,PP,rr,cc,dd,AS,bS)

dist = inf;

% # of conjunctions, # of continuous states
[noc,nos,nod] = size(cc);
cvx_quiet(1);
for ii = 1:nod
    if nargin>5
        if noc~=1
            error('DistEllipsoidFromPlane: If system dynamics are given, then the polyhedral set must be concave.');
        end
        ci = [cc(1,:,ii);cc(1,:,ii)*AS];
        if isempty(bS)
            di = [dd(:,ii);zeros];
        else
            di = [dd(:,ii);-cc(1,:,ii)*bS];
        end
    else
        ci = cc(:,:,ii);
        di = dd(:,ii);
    end
    % for each clause solve a convex optimization problem
    cvx_begin 
        variables x(nos) y(nos);
        minimize norm(x-y) 
        (x-x0)'*PP*(x-x0) <= rr
        ci*y <= di
    cvx_end
    dist = min(dist,cvx_optval);
end


