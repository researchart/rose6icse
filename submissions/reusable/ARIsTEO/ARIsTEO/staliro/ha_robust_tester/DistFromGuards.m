% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistFromGuards
% 
% DESCRIPTION:
% Computes the distance of the point x from the set of halfspaces that 
% represent the guard for the transition of the hybrid automaton under the
% additional constraint of the direction of the vector field in the 
% discrete location.
%
% Note: in order to reduce the computation time of this function we do not
% check whether c*x<=d. This needs to be verified before this function 
% is called.
%
% INTERFACE:
%   [dist,x0] = DistFromGuards(x,c,d,A,b,opt)
%
% INPUTS:
%   - x: the current continuous state of the HA
%   - c,d: the list of/or arrays-vectors that define the polyhedra for the 
%          transition guards, i.e. c*x=d, see testha.m
%   - A,b: the matrix and the vector that model the dynamics in the 
%          current discrete location of the HA, i.e. dx/dt = Ax+b
%
% CHANGE: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   - opt: an optional vector of parameters 
%   - opt(1): 0 use quadprog (default)
%             1 use cvx (cvx and sedumi must be installed)
%   - opt(2): 0 take into account the dynamics of the system on the guard
%               set (default option)
%             1 ignore system dynamics
%
% OUTPUTS:
%   - dist: the minimum distance of a x from the polyhedra
%   - x0: the point that minimizes the distance
%
% See also: testha, computeMinDist
%
% Note: Needs verification when we have union of polyhedra
%

% Georgios Fainekos - GRASP Lab - Last update 2006.10.11

function [dist,x0] = DistFromGuards(xx,cC,dC,AS,bS,opt)

global testOptions

if nargin<6
    if isempty(testOptions) 
        opt = [0 0];
    else
        opt = [testOptions.QPSolv testOptions.IgnoreDyn];
    end
else
    opt = [0 0];
end
    

% Solvers' options
if opt(1)
    cvx_quiet(1);
    options = [];
else
    options = optimset('LargeScale','off','Display','off');
end

if isa(cC,'double')
    % Case: One polyhedron
    if opt(2)
        [dist,x0] = DistFromPolyhedra(xx,cC,dC);
    else
        [dist,x0] = DistFromGuard(xx,cC,dC,AS,bS,opt,options);
    end
else
    % Case: Union of polyhedra
    % The optimization should fail only if the vector field is always positive
    % along the guard
    dist = inf;
    x0 = NaN; 
    % For each clause solve a QP and pick the min distance. 
    for ii=1:length(cC)
        if opt(2)
            [tmpdist,tmpx0] = DistFromGuard(xx,cC{i},dC{i},AS,bS,opt,options);
        else
            [tmpdist,tmpx0] = DistFromPolyhedra(xx,cC{i},dC{i},opt(1));
        end
    end
    if tmpdist<dist
        dist = tmpdist;
        x0 = tmpx0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dist,x0] = DistFromGuard(xx,cC,dC,AS,bS,opt,options)
% The optimization should fail only if the vector field is always positive
% along the guard
dist = inf;
x0 = NaN; 
% # of conjunctions, # of continuous states
[noc,nos] = size(cC);
% Compute the surfaces that define the change of direction for the vector
% field
cA = cC*AS;
cb = cC*bS;
% Analytical solution when there is only one halfspace
if noc==1
    [dist,x0] = DistProjFromPlane(xx,cC,dC);
    if cA*x0+cb>0
        C = [cC;cA];
        D = [dC;-cb];
        CM = C*C';
        if abs(det(C*C'))<1e-14 
            % If the half spaces are parallel
            dist = inf;
            x0 = NaN;
        else
            % get the distance
            Ctmp = CM\(D-C*xx);
            x0 = xx+C'*Ctmp;
            % x0 = xx+C'*inv(CM)*(D-C*xx);
            dist = norm(x0-xx);
        end
    end
else
    % Solve a QP and pick the min distance. 
    for ii=1:noc
        if opt(1)
            [tmpdist,tmpx0] = cvx_wrapper(nos,ii,xx,cA(ii,:),cb(ii),cC,dC);
        else
            [tmpdist,tmpx0] = qp_wrapper(nos,ii,xx,cA(ii,:),cb(ii),cC,dC,options);
        end
        if tmpdist<dist
            dist = tmpdist;
            x0 = tmpx0;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dist,x0] = cvx_wrapper(nn,ii,xx,cA,cb,cC,dC)
ci = cC(ii,:);
di = dC(ii);
cC(ii,:) = [];
dC(ii) = [];
cvx_begin 
    variable x(nn)
    minimize norm(x-xx) 
    cA*x+cb <= 0
    ci*x == di
    cC*x <= dC
cvx_end 
% Only for debugging for 1 half space
% cvx_begin 
%     variable x(nn)
%     minimize norm(x-xx) 
%     cA*x+cb <= 0
%     ci*x == di
% cvx_end 
dist = cvx_optval;
if dist==inf
    x0 = NaN;
else
    x0 = x;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dist,x0] = qp_wrapper(nn,ii,xx,cA,cb,cC,dC,options)
ci = cC(ii,:);
di = dC(ii);
cC(ii,:) = [];
dC(ii) = [];
[zz,fval,eflag] = quadprog(2*eye(nn),[],[cA;cC],[-cA*xx-cb;dC-cC*xx],ci,di-ci*xx,[],[],[],options);
% Only for debugging for 1 half space
% [zz,fval,eflag] = quadprog(2*eye(nn),[],cA,-cA*xx-cb,ci,di-ci*xx,[],[],[],options);
if eflag==1
    x0 = zz+xx;
    dist = sqrt(fval);
elseif eflag==-2
    x0 = NaN;
    dist = inf;
else
    error('One of the optimizations did not converge');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

