% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Class definition for Simulated Annealing for stochastic system parameters
%
% sa_cold_stoch_params = SA_Cold_Stoch_parameters
%
% The above code sets the default parameters for Simulated Annealing for 
% stochastic system optimization:
%
% n_tests = 1000; 
%       Number of tests in one run of the algorithm
% J_bound = 50; 
%       Perform J extractions per MC sample
% delta = 0.1; 
%       Delta parameter (see: Abbas et al. Robustness-Guided Temporal Logic 
%       Testing and Verification for Stochastic Cyber-Physical Systems,
%       CYBER 2014
% logAdjParameter = 1;  
%       Scaling parameter for squashing function
% nBurnOutSamples = 0;  
%       Number of burn-out samples after n_tests
% proposalMethod = 'hit-and-run';  
%       'uniform' or 'hit-and-run' candidate proposal method
% sa_params = SA_Taliro_parameters;
%       The default parameters for SA_Taliro
%
% To change the default values to user-specified values use the default
% object already created to specify the properties.
%
% E.g., to change sa_cold_stoch_J_bound type:
%
% sa_cold_stoch_params.J_bound = 50;
%
% See also: staliro_options

% (C) 2013, Bardh Hoxha, Arizona State University
% (C) 2015, Georgios Fainekos, Arizona State University

classdef SA_Cold_Stoch_parameters

    properties
        n_tests = 1000                   % Number of tests in one run of the algorithm
        J_bound = 50;                    % Perform J extractions per MC sample
        delta = 0.1;                     % Delta parameter
        logAdjParameter = 1;             % Scaling parameter for squashing function
        nBurnOutSamples = 0;             % Number of burn-out samples after n_tests
        proposalMethod = 'hit-and-run';  % 'uniform' or 'hit-and-run' candidate proposal method
        sa_params = SA_Taliro_parameters; 
    end
    
    methods
        
        function obj = SA_Cold_Stoch_parameters(varargin)
            if nargin>0
                error(' GA_Taliro_parameters : Please access directly the properties of the object.')
            end
        end
        
        function y = squash(obj, r)
            % Squash input value between 0 and 1
            % squashedValue = sa_cold_opts.squash(value)
            % Value can be 2D array
            y = 1./(1+exp(r./obj.logAdjParameter));
        end
        
    end
    
end

