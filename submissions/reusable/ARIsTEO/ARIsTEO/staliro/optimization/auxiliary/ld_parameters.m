% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ld_parameters
% Class definition for Local Descent parameters 
%
% ld_params = ld_parameters
%
% The above code sets the default parameters in the object ld_params.
%
% To change the default values, access the object's properties directly.
%
% local_minimization_algo = 'RED';               
%       Algorithm used to perform local descent from chosen candidates.
%       Supported algos are RED and NM.
%
% red_min_ellipsoid_radius = 0;       
%       If a robustness ellipsoid is too small (e.g. its nominal
%       trajectory gets very close to some guard), then it may not be
%       worth searching in it. This property gives the smallest radius of
%       an ellipsoid worth searching in. Note it doesn't make sense to
%       have it be an absolute value. Rather, it should be set by the
%       user to some percentage of the radius or volume of the search
%       space. If you want to search in all ellipsoids regardless of
%       size, set this to 0.
%
% red_nb_ellipsoids = 10;
%       Maximum nb of ellipsoids that will be computed by RED, and over
%       which it will attempt a descent of the robustness
%
% max_nbse = 5000;        
%       Maximum nb of system evaluations (i.e. simulated trajectories)
%       if doing local descent.
%       When doing local descent, the user may specify a maximum nb of
%       system evaluations for the entire staliro run. This does not have
%       to be the same as n_tests: if smaller, the run will abort when it
%       hits max_nbse. If larger, the excess is used by the local descent
%       algorithm.
%       If local descent is not used (apply_local_descent = 0), then this
%       option is ignored.
%
% red_descent_in_ellipsoid_algo = 'UR';
%       In each ellipsoid, an optimization is run to find a descent
%       direction. This variable determines which algo is run to find
%       that descent.
%       Allowed value; UR (for Uniform Random), SQP, NelderMead
%
% red_hard_limit_on_ellipsoid_nbse = 1;
%       For some local descent algorithms (e.g. UR), it is desirable to
%       set a hard limit on how many trajectories may be simulated in a
%       given ellipsoid. E.g. for UR, which doesn't have a convergence
%       criterion, such a hard limit is necessary to avoid using all nbse
%       on one ellipsoid (and one sample). For others, like NelderMead,
%       this is optional.
%
% See also: staliro_options, SA_Taliro_parameters, MS_Taliro_parameters

% (C) 2013, Houssam Abbas, Arizona State University
% (C) 2015, Georgios Fainekos, Arizona State University
    
    properties      

        local_minimization_algo = 'RED';               
        red_min_ellipsoid_radius = 0;
        red_nb_ellipsoids = 10;
        max_nbse = 5000;

    end      
    
    properties(Dependent)

        red_descent_in_ellipsoid_algo;
        red_hard_limit_on_ellipsoid_nbse;
        
    end
    
    properties(Access=private)
        
        priv_red_descent_in_ellipsoid_algo = 'UR';
        priv_red_hard_limit_on_ellipsoid_nbse = 1;
        
    end
    
    methods
        function obj = ld_parameters(varargin)
            if nargin>0
                error(' ld_parameters : Please access directly the properties of the object.')
            end
        end
    end
    
    methods

        function nbse = get.red_hard_limit_on_ellipsoid_nbse(obj)
            nbse = obj.priv_red_hard_limit_on_ellipsoid_nbse;
        end
        
        function set.red_hard_limit_on_ellipsoid_nbse(obj,value)
            if strcmp(obj.priv_red_descent_in_ellipsoid_algo,'UR')
                obj.priv_red_hard_limit_on_ellipsoid_nbse = 1;
            else
                obj.priv_red_hard_limit_on_ellipsoid_nbse = value;
            end
        end
        
        function algo = get.red_descent_in_ellipsoid_algo(obj)
            algo = obj.priv_red_descent_in_ellipsoid_algo;
        end
        
        function set.red_descent_in_ellipsoid_algo(obj,value)
            if ~(strcmp(value,'UR') || strcmp(value,'SQP') || strcmp(value, 'NM') || strcmp(value, 'NelderMead'))
                error([' ld_parameters : Unsupported value of red_descent_in_ellipsoid_algo: ', value])
            end
            if strcmp(value, 'NM') 
                value = 'NelderMead';
            end
            if strcmp(value,'UR')
                obj.priv_red_hard_limit_on_ellipsoid_nbse = 1;
            end
            obj.priv_red_descent_in_ellipsoid_algo = value;
        end
        
        function set.local_minimization_algo(obj,value)
            if (strcmp(value,'RED') || strcmp(value, 'NM'))
                obj.local_minimization_algo = value;
            else
                error(' ld_parameters : You specified an unsupported local_minimization_algo, only supported values are RED and NM.')
            end
        end
        
    end
    
end

