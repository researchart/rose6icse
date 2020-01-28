% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Class definition for Ant Colony Optimization algorithm
% 
% aco_params = ACO_Taliro_parameters
%
% The above code sets the default parameters the ACO optimization 
% algorithm:
%
% n_tests				% Number of tests
% ants_number = 20      % Number of ants
%                              
% To change the default values to user-specified values use the default 
% object already created to specify the properties.                             
%                              
% E.g., to change the number of ants:
%
% aco_params.ants_number = 1000;
% 
% See also: staliro_options
%
% (C) 2013, Bardh Hoxha, Arizona State University
% (C) 2015, Georgios Fainekos, Arizona State University

classdef ACO_Taliro_parameters
    
    properties
        n_tests = 1000;
		ants_number = 20;
    end
    
    methods        
        function obj = ACO_Taliro_parameters(varargin)
            if nargin>0
                error(' ACO_Taliro_parameters : Please access directly the properties of the object.')
            end
        end
    end
    
end

        