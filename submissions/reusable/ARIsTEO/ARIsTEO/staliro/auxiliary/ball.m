% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Implements an n-dimensional ball
% b = ball(center, radius, opts);
% opts.strict = 1 indicates the use of strict inequalities when
% evaluating if a point is in this set or not. Default: 0.
% opts.AND_or_OR indicates either that the p_i's must all be TRUE for a
% point be considered in ball ('AND'), or that at least one must be TRUE for the
% point to be considered in ball ('OR'). Default: 'AND'
% This, and any other class that can be used in unsafeset, must have:
% - 'pseudo_indicator' method satisfying:
%     set = {x|set.pseudo_indicator(x) <= 0}
%   Signature: slack = b.pseudo_indicator(x)
% - 'distance_to_me' method returns distance of point x to the set.
%   Signature: [dist p] = b.distance_to_me(x)
%   dist is distance of pnt x to the set, and p is the nearest point on the
%   set to x
% - 'pseudo_indicator_dimension' property
%       length of vector returned by method pseudo_indicator

classdef ball
    properties
        center;
        radius;
        pseudo_indicator_dimension;
        strict;
        AND_or_OR;
    end
    
    methods
        function obj = ball(xc,r, opts)
            if size(xc,2) > 1 % row vector
                xc = xc';
            end
            obj.center = xc;
            obj.radius =r;
            % length of vector returned by method pseudo_indicator
            obj.pseudo_indicator_dimension = 1;
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
        
        % B(xc,r) = {x | pseudo_indicator(x) <= 0}
        function slack = pseudo_indicator(obj,x)
            slack = norm(x - obj.center) - obj.radius;
        end
        
        function yes = pnt_is_in(obj,x)
            yes = 0;
            if obj.strict
                pi = (obj.pseudo_indicator(x) < 0);
            else
                pi = (obj.pseudo_indicator(x) <= 0);
            end
            aoi = obj.AND_or_OR;
            if (strcmp(aoi,'AND') && sum(pi)==length(pi)) || (strcmp(aoi,'OR') && find(pi))
                yes =1;
            end
            
        end
        
        function [d nearest_pnt_on_me] = distance_to_me(obj, x)
            d = norm(x - obj.center) - obj.radius;
            if d <= 0
                d = 0;
                nearest_pnt_on_me = x;
            else
                nearest_pnt_on_me = x + (d/norm(x-obj.center))*(obj.center -x);
            end
        end
        
    end % methods
end % class

