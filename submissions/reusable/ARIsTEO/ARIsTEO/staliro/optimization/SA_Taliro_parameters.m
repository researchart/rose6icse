% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef SA_Taliro_parameters
% Class definition for Simulated Annealing parameters with Monte-Carlo
% Sampling
%
% sa_params = SA_Taliro_parameters
%
% The above code sets the default parameters in the object sa_params.
%
% Default parameter values:
%
% n_tests = 1000        
%       Number of iterations
% fRestarts = 2500;     
%       Number of iterations before restarting
% acRatioMax = 0.55;    
%       Maximum acceptance ratio
% acRatioMin = 0.45;    
%       Minimum acceptance ratio
% betaXStart = -15.0;   
%       Initial continuous beta parameter
% betaXAdap = -15.0;    
%       Continuous beta adaptation param. as percentage
% betaLStart = -15.0;   
%       Initial discrete beta parameter
% betaLAdap = 50;       
%       Discrete beta adaptation param. as percentage
% dispStart = 0.75;     
%       Initial displacement
% dispAdap = 10;        
%       Displacement adaptation param. as percentage
% maxDisp = 0.99;      
%       Maximum possible displacement
% minDisp = 0.01;      
%       Minimum possible displacement
% max_time = inf;
%       Time budget for optimization: when the stopwatch timer reaches this
%       value the algorithm is terminated. as seconds 
% apply_local_descent = 0; 
%       0: do not perform or 
%       1: perform 
%       local descent to judiciously chosen candidates in SA_Taliro
% apply_local_descent_this_run = 0; 
%       Local descent, if enabled, will be disabled once max_nbse is 
%       exceeded. This disabling lasts only for one run, since a new run 
%       starts with a new budget of nbse.
% apply_GD = 0;
%       0: do not perform or 
%       1: perform 
%       Applies Gradient Descent to SA samples if it's stuck
% ld_params = ld_parameters; 
%       Local descent parameters see ld_parameters 
% init_sample = [];
%       If it is desired to start the simulated annealing algorithm from a
%       specific sample, then use the init_sample property. For example, if
%       you have run staliro before with output results, you can set:
%           sa_params.init_sample = results.run(1).bestSample;
% GD_params = GD_parameters;
%       Gradient descent parameters see ld_parameters
% To change the default values to user-specified values use the default
% object already created to specify the properties.
%
% E.g., to change the number of iterations before Simulated Annealing is
% reinitialized to a random position to 1000 type:
%
% sa_params.fRestarts = 1000;
%
% See also: SA_Taliro, staliro_options, ld_parameters, GD_parameters

% (C) 2011, Georgios Fainekos, Arizona State University
% (C) 2013, Bardh Hoxha, Arizona State University
% (C) 2019, Shakiba Yaghoubi, Arizona State University

    properties
        n_tests = 1000;
        fRestarts = 2500;
        acRatioMax = 0.55;
        acRatioMin = 0.45;
        betaXStart = -15.0;
        betaXAdap = 50;
        betaLStart = -15.0;
        betaLAdap = 50;
        dispStart = 0.75;
        dispAdap = 10;
        maxDisp = 0.99;
        minDisp = 0.01;
        max_time = inf;
        apply_local_descent = 0;
        apply_local_descent_this_run = 0;
        apply_GD = 0;
        ld_params = ld_parameters;
        init_sample = [];
        GD_params = GD_parameters;
    end
    
    methods
        function obj = SA_Taliro_parameters(varargin)
            if nargin>0
                error(' SA_Taliro_parameters : Please access directly the properties of the object.')
            end
              
        end
    end
    
end

