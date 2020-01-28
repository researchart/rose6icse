% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Class definition for the Genetic algorithm
% 
% ga_params = GA_Taliro_parameters
%
% The above code sets the default parameters for Genetic Algorithm 
% optimization:
%
% ga_options = gaoptimset(gaoptimset(@ga),'MutationFcn',@mutationadaptfeasible); 
%       See gaoptimset for instructions on the GA options. If n_tests is
%       not empty, then when ga_options is set to a new object with GA
%       options, the properties 'Generations' and 'PopulationSize' will be
%       overwritten as explained below. Please set n_tests = [] if 
%       ga_options will be set directly.
%
%       Remark: when the search space has polyhedral constraints, then the
%       mutation function @mutationadaptfeasible does not perform well. It
%       is recommended that you use the option @mutationuniform.
%       Recommended value: {@mutationuniform,0.2}.
%
% n_tests = [];
%       The maximum number of tests can be set through the gaoptimset by
%       controlling 'Generations' and 'PopulationSize'. If a numeric value
%       is set in n_tests, then the total number of tests will be enforced
%       by assuming PopulationSize = 50;
%                             
% To change the default values to user-specified values use the default 
% object already created to specify the properties.                             
%                              
% E.g., to change the ga_options type:
% 
% ga_params.ga_options = gaoptimset(@ga,'Generations',200);
% 
% See also: staliro_options, GA_Taliro

% (C) 2013, Bardh Hoxha, Arizona State University
% (C) 2015, Georgios Fainekos, Arizona State University

classdef GA_Taliro_parameters
    
    properties(Dependent)
        ga_options;
        n_tests;
    end
    properties(Access=private)
        priv_ga_options = gaoptimset(gaoptimset(@ga),'MutationFcn',@mutationadaptfeasible);
        priv_n_tests = [];
    end
    
    methods        
        function obj = GA_Taliro_parameters(varargin)
            if nargin>0
                error(' GA_Taliro_parameters : Please access directly the properties of the object.')
            end
        end
    end
        
    methods        
        
        function ga_opt = get.ga_options(obj)
            ga_opt = obj.priv_ga_options;
        end

        function obj = set.ga_options(obj,value)
            obj.priv_ga_options = value;
            
        end
        
        function ga_opt = get.n_tests(obj)
            ga_opt = obj.priv_n_tests;
        end

        function obj = set.n_tests(obj,value)
            obj.priv_n_tests = value;
            if ~isempty(value) && isscalar(value)
                if floor(value/50)~=ceil(value/50)
                    error(' GA_Taliro_parameters : 50 must be a divisor of the total number of tests')
                else
                    obj.priv_ga_options = gaoptimset(obj.priv_ga_options,'PopulationSize',50,'Generations',value/50);
                end
            end
        end
        
    end
end

        