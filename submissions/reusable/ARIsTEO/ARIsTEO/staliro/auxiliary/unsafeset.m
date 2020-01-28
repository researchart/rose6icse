% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef unsafeset
    % NAME
    %   unsafeset - class to describe a set
    %
    % SYNOPSYS
    %   MY_U = UNSAFESET([DJ1 DJ2])
    %
    % DESCRIPTION
    %
    % Defines a set within a hybrid system.    
    % The set can be the union of several subsets. Each of these subsets is called
    % a disjunct in this, as in:
    % unsafe_set = {x | x \in disjunct1 OR x \in disjunct2 OR x \in disjunct 3...}
    % Properties:
    %   descriptions : an array of disjuncts. Each disjunct is
    %       a struct with at least these fields:
    %       - set : a class. The particular class depends on the particular
    %         disjunct we are trying to describe. E.g. 'ball'. Any
    %         set must have a 'pseudo_indicator' method satisfying:
    %             set = {x|set.pseudo_indicator(x) <= 0}
    %         It must also have a 'distance_to_me' method:
    %             [dist p] = set.distance_to_me(x)
    %         dist is distance of pnt x to the set, and p is the nearest point on the set to x
    %         See help of class 'ball' for details.
    %       - loc : list of locations of this disjunct (in the hybrid system).
    %   locations : an array of integers.
    %       The set is distributed over the locations in locations[]
    %   AND_or_OR : an array of strings, possible values 'AND' or 'OR'
    %       If AND_or_OR(i) = 'AND', then all inequalities of ith disjunct must
    %       be satisfied for the point to be considered in it (i.e. the vector
    %       output of descriptions(i).set.pseudo_indicator must have all
    %       entries negative). If 'OR', then at least one inequality must be
    %       satisfied. Default = 'AND'.
    %
    % Methods:
    %   distance_to_me : [d, nearest_pnt_on_me] =  my_u.distance_to_me(x)
    %       d                 = distance from (col vector) x to this set.
    %       nearest_pnt_on_me = pnt on set nearest to x.
    %       If x \in set, then d = 0 and nearest_pnt_on_me = x.
    %   pseudo_indicator : p = pseudo_indicator(x)
    %   hybrid_inclusion: 1|0 = my_u.hybrid_inclusion(h)
    %       Returns 1 if locations match and x in set
    %   zero_robustness:  1|0 = zero_robustness(h)
    %       Returns 1 if locations match and distance <= 0
    %
    % Example:
    %       % disjunct 1
    %       >> xc = [-1 -2 -3];  r = 0.5;
    %       >> cj1.set =ball(xc,r);        cj1.loc = 1;
    %       % disjunct 2
    %       >> A = [1 3 4; 4 3 8];  b = [0; 0];
    %       >> cj2.set = polyho(A, b); cj2.loc = [4 5];
    %       >> unsafe = unsafeset([cj1 cj2]);
    %       Above describes an unsafe set which is the union of a ball (cj1)
    %       and a polyhedron (cj2).
    %       The ball is in location 1; cj1.set is of class 'ball'.
    %       The polyhedron is in locations 4 and 5; cj2.set is of class 'polyho'.
    properties
        % one element per disjunct.
        descriptions = [];
        locations = [];
        locas = [];
    end
    
    methods
        function obj = unsafeset(indescriptions)
            obj.descriptions = indescriptions;
            for d=1:length(indescriptions)
                obj.locations = [obj.locations indescriptions(d).loc];
            end
            obj.locations = unique(obj.locations);
        end
        
        function [d, nearest_pnt_on_me] = distance_to_me(obj, x)
            nbdisjuncts = length(obj.descriptions);
            dist = zeros(1,nbdisjuncts);
            pnts = zeros(length(x), nbdisjuncts);
            for i=1:nbdisjuncts
                [dist(i) pnts(:,i)] = obj.descriptions(i).set.distance_to_me(x);
            end
            [d ix_min] = min(dist);
            nearest_pnt_on_me = pnts(:,ix_min);
        end
        
        function yes = same_location_as_me(obj, h, all)
            % If h is in a location of disjunct i, returns i (>0).
            % Else, returns 0.
            % If h happens to be in locations of several disjuncts,
            %    If all is not provided OR all == 0
            %        the index i of the first disjunct is returned.
            %    else
            %        all disjuncts' indices are returned as a list
            if nargin <= 2 || ~all
                yes = 0;
                for i=1:length(obj.descriptions)
                    for ll=obj.descriptions(i).loc
                        if h(1)== ll
                            yes=i;
                            break;
                        end
                    end
                end
            else
                yes =[];
                for i=1:length(obj.descriptions)
                    for ll=obj.descriptions(i).loc
                        if h(1)== ll
                            yes=[yes i];
                        end
                    end
                end
            end
        end
        
        
        function p = pseudo_indicator(obj, x)
            p=[];
            for i=1:length(obj.descriptions)
                p=[p;obj.descriptions(i).set.pseudo_indicator(x)];
            end
        end % function pseudo_indicator
        
        function yes = hybrid_inclusion(obj, h)
            % For h to be 'hybridly' included in the unsafeset, the
            % locations must match, and the set must include the continuous
            % part of h.
            % If h is hybridly included in disjunct i, returns i (>0).
            % Else, returns 0.
            yes = 0;
            ix_sameloc = obj.same_location_as_me(h,1);
            for i = ix_sameloc
                if obj.descriptions(i).set.pnt_is_in(h(3:end)')
                    yes = i;
                    break;
                end
            end
        end % function hybrid_inclusion
        
        function yes = zero_robustness(obj, h)
            % For h to have zero robustness w.r.t unsafeset, the
            % locations must match, and the distance must be 0. Note this is different from hybrid_inclusion,
            % in the case where the unsafe set is open: in this case,
            % distance can be 0 though h \notin \unsafe.
            % If h has zero robustness to disjunct i, returns i (>0).
            % Else, returns 0.
            yes = 0;
            ix_sameloc = obj.same_location_as_me(h,1);
            for i = ix_sameloc
                if obj.distance_to_me(h(3:end)') <= 0
                    yes = i;
                    break;
                end
            end
            
        end % function hybrid_inclusion
        
    end % methods
    
end