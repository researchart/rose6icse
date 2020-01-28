% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Implements an n-dimensional polyhedron with m faces, s.t.
% polyhedron = {x | Hx <= K}, H: m-by-n matrix, K: m-by-1 vector
% >> p = polyho(H, K, opts);
% with opts = struct('AND_or_OR', _'AND'_|'OR', 'strict', _0_|1)
% Internally, uses mpt's polytope class.
% See help for class ball for minmimum interface: 
% >> help ball

classdef polyho
    properties
        H;
        K;
        polytopey;
        pseudo_indicator_dimension;
        % Common interface elements
        strict;
        AND_or_OR;
    end
    
    methods
        function obj = polyho(H, K, opts)
            Hs=[]; Ks=[];
            for i=1:size(H,1) % get rid of all 0 entries
                if ~isempty(find(H(i,:),1))
                    Hs = [Hs;H(i,:)];
                    Ks = [Ks; K(i)];
                end
            end
            obj.H = Hs; obj.K = Ks;         
            % length of vector returned by method pseudo_indicator
            obj.pseudo_indicator_dimension = size(obj.H,1);
            % Common interface elements
            if nargin < 3
                opts = struct('AND_or_OR', 'AND', 'strict', 1);
            end
            if isfield(opts,'strict') 
                obj.strict = opts.strict;
            else
                obj.strict=0;                
            end
            if isfield(opts,'AND_or_OR') 
                obj.AND_or_OR = opts.AND_or_OR;
            else
                obj.AND_or_OR = 'AND';
            end                
        end
        
        % polyhedron = {x | pseudo_indicator(x) <= 0}
        function slack = pseudo_indicator(obj,x)
            slack = obj.H*x - obj.K;
        end
        
        function yes = pnt_is_in(obj,x)
            yes = 0;
            if obj.strict
                pi = (obj.pseudo_indicator(x) < 0);
            else
                pi = (obj.pseudo_indicator(x) <= 0);
            end
            aoi = obj.AND_or_OR;
            if (strcmp(aoi,'AND') && sum(pi)==length(pi)) || (strcmp(aoi,'OR') && ~isempty(find(pi,1)))
                yes =1;                
            end
            
        end
        
        function [d nearest_pnt_on_me] = distance_to_me(obj, x)
            % x must be a column vector
            [dist,inSet,proj] = SignedDist(x,obj.H,obj.K);
            if inSet
                d = 0;
                nearest_pnt_on_me = x;
            else
                d = abs(dist);
                nearest_pnt_on_me = proj;
            end
        end
        
%         function [d nearest_pnt_on_me] = distance_to_me(obj, x)
%             % x must be a column vector
%             dist = zeros(1, obj.pseudo_indicator_dimension);
%             proj = zeros(length(x), obj.pseudo_indicator_dimension);
%             % get distance from each face of the polyhedron
%             for i=1:obj.pseudo_indicator_dimension
%                 [dist(i), proj(:,i)] = DistProjFromPlane(x, obj.H(i,:), obj.K(i));
%             end            
%             [m ixm] = max(obj.pseudo_indicator(x));
%             if (m >= 0) % point is outside (or on boundary of) polyhedron
%                 d = dist(ixm); nearest_pnt_on_me = proj(:,ixm);
%             else % pnt is inside polyhedron
%                 d = 0; nearest_pnt_on_me = x;
%             end
%         end
        
    end % methods
end % class


