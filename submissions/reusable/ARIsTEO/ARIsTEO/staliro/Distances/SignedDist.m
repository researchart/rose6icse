% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION SignedDist
% 
% DESCRIPTION: 
%   Compute the signed distance of the point x from an intersection of 
%   halfspaces 
%               /\_i a_i*x <= b_i
%   or a union of halfspaces
%               \/_i a_i*x <= b_i
%
% INTERFACE: 
%   [dist,inSet,proj] = SignedDist(x,A,b)
%
% INPUTS:
%   - x: the point
%   - A, b: 
%        * If A is empty, then it represents the set R^n
%        * If A is a numeric array 
%                     A = [a_1; a_2; ...; a_m] 
%          and b is a numeric column vector
%                     b = [b_1; b_2; ...; b_m], 
%          then the pair (A, b) represents the conjuction of the 
%          halfspaces a_i*x <= b_i
%        * If A is a cell vector 
%                     A = {a_1; a_2; ...; a_m} 
%          and b is a cell vector
%                     b = {b_1; b_2; ...; b_m}, 
%          then the pair (A, b) represents the disjunction of the 
%          halfspaces a_i*x <= b_i
%
% OUTPUTS:
%   - dist: the minimum distance of the point x from the set of hyperplanes
%           the distance is positive if the point is inside the set
%           and negative if the point is not inside the set
%   - inSet: 1 if the point is in the set, 0 otherwise
%   - proj: the projection of the point x on the set of half spaces
%
% Notes: 
% 1) This function is not optimal when the sets are 1D.
% 2) This function does not do any error checking for afficiency; use it
%    with caution

% (C) Georgios Fainekos 
%
% History:
% 2012.09.13 - Added projected point
% 2006.08.07 - 1st stable version

function [dist,inSet,proj] = SignedDist(x,A,b)

[noc,nos,nod] = size(A);

if isempty(A)
    dist = inf;
    inSet = 1;
    return
end

if nod~=1  
    error('The set must be convex');
end

inSet = isPointInSet(x,A,b);

if iscell(A) % Case : union of halfspaces
    if inSet
        % if the point is in the set -> compute the complement of the set
        A_tmp = [];
        b_tmp = [];
        for i = 1:length(A)
            assert(size(A{i},1)==1)
            A_tmp = [A_tmp;-A{i}]; %#ok<AGROW>
            b_tmp = [b_tmp;-b{i}]; %#ok<AGROW>
        end
        [dist,proj] = DistFromPolyhedra(x,A_tmp,b_tmp);
    else
        %if the point is outside the set
        len_A = length(A);
        len_x = length(x);
        A_tmp = zeros(1,len_x,len_A);
        b_tmp = zeros(1,len_A);
        for i = 1:length(A)
            A_tmp(1,:,i) = A{i};
            b_tmp(i) = b{i};
        end
        [dist,proj] = DistFromPolyhedra(x,A_tmp,b_tmp);
        dist = -dist;
    end
else % Case : intersection of halfspaces
    if inSet 
        % if the point is in the set
        dist = inf;
        proj = x;
        for i = 1:noc
            tmp_min = DistFromPlane(x,A(i,:),b(i));
            if tmp_min<dist
                dist = tmp_min;
                proj = ProjOnPlane(x,A(i,:),b(i));
            end
        end
    else
        %if the point is outside the set
        [dist,proj] = DistFromPolyhedra(x,A,b);
        dist = -dist;
    end    
end

end
        

    
    