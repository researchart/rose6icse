% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Given a set S , describes a set E which contains S, and whose boundary is
% at a prescribed length dist from the boundary of S. Thus
% E  ={ x | distance(x,S) = dist}

classdef setenvelope
    properties        
        pseudo_indicator_dimension;
        distance;
        set;
    end
    
    methods
        function obj = setenvelope(around_set, dist)            
            obj.pseudo_indicator_dimension = 1;
            obj.distance = dist;
            obj.set = around_set;
        end
        
        function slack = pseudo_indicator(obj,x)
            slack = obj.set.distance_to_me(x) - obj.distance ;
        end
        
        function [d nearest_pnt_on_me] = distance_to_me(obj, x)
            [d2set nearest_on_set] = obj.set.distance_to_me(x);            
            d = d2set - obj.distance;
            if d <= 0
                d = 0;
                nearest_pnt_on_me = x;
            else
                nearest_pnt_on_me = x + (d/d2set)*(nearest_on_set -x);
            end
        end
        
    end % methods
end % class

