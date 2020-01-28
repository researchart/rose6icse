% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef MS_Taliro_parameters
% Class definition for Multi-Start parameters 
%
% ms_params = MS_Taliro_parameters;
%
% The above code sets the default parameters in the object ms_params.
%
% To change the default values to user-specified values use the default
% object already created to specify the properties.
%
% E.g., to change the number of tests:
%
% ms_params.n_tests = 1000;
%
% See also: staliro_options
%
% (C) 2011, Georgios Fainekos, Arizona State University
% (C) 2013, Houssam Abbas, Arizona State University
    
    properties
        
        % nb of initial points for multi-start
        n_tests = 10;              
        
        % If not 0, will apply local descent to judiciously chosen candidates
        % in SA_Taliro
        apply_local_descent = 0;
        
        % Local descent, if enabled, will be disabled once max_nbse is exceeded.
        % This disabling lasts only for one run, since a new run starts with a new
        % budget of nbse.
        apply_local_descent_this_run = 0;

        % When refining the Multi-Start grid, choose new points that are
        % strictly inside the initial set
        strictly_inside = 1;
        
        % Local descent parameters
        ld_params = ld_parameters;
                
    end
    
    methods
        function obj = MS_Taliro_parameters(varargin)            
            if nargin>0
                error(' MS_Taliro_parameters : Please access directly the properties of the object.')
            end
        end
    end
    
end

