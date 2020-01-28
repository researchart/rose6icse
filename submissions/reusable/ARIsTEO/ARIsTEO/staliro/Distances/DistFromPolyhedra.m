% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistFromPolyhedra
% 
% DESCRIPTION: 
%   Compute the distance and the projection of the point x to a union of 
%   polyhedra P = { x | \/_i /\_j a_ij*x<=b_ij } 
%
% INTERFACE: 
%   [dist,x0] = DistFromPolyhedra(x,A,b,opt)
%
% INPUTS:
%   - x: the point
%   - A: A list of 2D arrays (j,s) where each row contains one vector a_j  
%        of dimension (1*s), i.e. one conjunct of /\_j a_ij*x<=b_ij. 
%   - b: A list of column vectors (j) with the scalars for each
%        disjunctive clause.
%   - opt: 0 use quadprog (default)
%          1 use cvx (cvx and sedumi must be installed)
%
% OUTPUTS:
%   - dist: the minimum distance of the point x from the set of half spaces
%   - x0: the projection of the point x on the set of half spaces
%
% See also: DistProjFromPlane, DistFromPlane, ProjOnPlane
%

% Georgios Fainekos - GRASP Lab - Last update 2006.09.11

function [dist,x0] = DistFromPolyhedra(xx,AA,Bb,opt)
if nargin<4
    opt = 0;
end
dist = inf;
x0 = xx;
% # of conjunctions, # of continuous states, # of disjunctions
[noc,nos,nod] = size(AA);
[dumnoc,dumnod] = size(Bb);
if dumnoc~=noc || dumnod~=nod
    error(['The dimensions of arrays A and B do not match']);
end
if noc==1
    % In case there is only one halfspace in each disjunctive clause
    for ii=1:nod
        [ddum,xdum] = DistFromHalfSpace(xx,AA(:,:,ii),Bb(:,ii)); 
        [dist,jj] = min([dist,ddum]);
        if jj==2
            x0 = xdum;
        end
    end
else
    % for each clause solve a QP and pick the min distance of each clause
    if opt
        cvx_quiet(1);
    else
        % options = optimset('LargeScale','off','Display','off','Algorithm','interior-point-convex');
         v=ver('Matlab'); 
        if(isequal(v.Version,'7.11'))
            options = optimset('LargeScale','off','Display','off','Algorithm','interior-point');
        else
            options = optimset('Display','off','Algorithm','interior-point-convex');
        end
    end
    for ii=1:nod
        if opt
            [tmpdist,tmpx0] = cvx_wrapper(xx,AA(:,:,ii),Bb(:,ii),nos);
        else
            [tmpdist,tmpx0] = qp_wrapper(xx,AA(:,:,ii),Bb(:,ii),nos,options);
        end
        if tmpdist<dist
            dist = tmpdist;
            x0 = tmpx0;
        end
    end
end 

function [dist,x0] = cvx_wrapper(xx,Ai,Bi,nos)
cvx_begin 
    variable x(nos)
    minimize(norm(x-xx)) 
    Ai*x <= Bi; 
cvx_end 
x0 = x;
dist = cvx_optval;

function [dist,x0] = qp_wrapper(xx,Ai,Bi,nos,options)
[zz,fval,eflag] = quadprog(2*eye(nos),[],[Ai],[Bi-Ai*xx],[],[],[],[],[],options);
if eflag==1
    x0 = zz+xx;
    dist = sqrt(fval);
elseif eflag==-2
    x0 = xx;
    dist = inf;
elseif eflag==0
    assert(fval>=0,' DistFromPolyhedra: quadprog optimization failed!');
    warning([' DistFromPolyhedra: quadprog reached the maximum number of iterations. The distance computed may be wrong! Distance to polyhedral set: ',num2str(sqrt(fval))])
    x0 = zz+xx;
    dist = sqrt(fval);
else
    error([' DistFromPolyhedra: quadprog exited with flag ',num2str(eflag),'! Please see the quadprog help file']);
end

