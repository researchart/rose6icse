% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION isPointInSet
% 
% DESCRIPTION: 
%   Find if a vector x is inside a convex polyhedron defined as A*x<=b or
%   inside a set defined by a union of polyhedra A{i}*x<=b{i}
%
% INTERFACE: 
%   inSet = isPointInSet(x,A,b,str)
%
% INPUTS:
%   - x: the vector of size n x 1 
%   - A: either an array m x n where m is the number of constraints or a
%        cell vector where each cell is an array of size m x n
%   - b: a vector of size n x 1 or a cell vector where each cell is a
%        vector of size n x 1.
%   - str: (optional) if omitted then inequality is non-strict. If '<' is
%        provided, then strict inequality is used.
%
% OUTPUTS:
%   - inSet: 1 if a point is in the set, 0 otherwise
%
% Note: to optimize performance, no safety checks are performed
%
% See also: arePointsInSet, DistProjFromPlane, ProjOnPlane, DistFromPolyhedra
%

% (C) Georgios Fainekos - 2011 - Arizona State University

function inSet = isPointInSet(x,A,b,str)
    if nargin==3 || strcmp(str,'<=')
        comp = @le;
    elseif strcmp(str,'<')
        comp = @lt;
    else
        error(['isPointInSet: relation "',str,'" is not supported'])
    end
    if iscell(A)
        inSet = 0;
        for ii = 1:length(A)
            if min(comp(A{ii}*x,b{ii}))
                inSet = 1;
                return
            end
        end
    else
        inSet = min(comp(A*x,b));
    end
end

