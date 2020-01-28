% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef GD_parameters
% Class definition for Gradient Descent parameters. 
%
% Note that in order to use GD, the Simulink model name should be provided. 
% Also, input output ports for linearization should be specified in the
% corresponding Simulink model using linear analysis points. If the 
% specification is on an output, the output linear analysis point should
% be placed on its corresponding port.
%
% GD_params = GD_parameters
%
% The above code sets the default parameters in the object GD_params.
%
% Default parameter values:
% GD_func = 'Apply_Opt_GD_default';
%      The function that applies GD on the sample
% no_suc_TH = 2;
%       The minimum number of iterations without success (acceptance)
%       before switching to local optimal search
% no_dec_TH = 5;
%       The minimum number of iterations without decrease in robustness
%       before switching to local optimal search
% init_GD_step = 10;
%      The step size for GD initially
% min_GD_step = 0.01;
%      Minimum step size for checking improvement in the GD direction
% model = '';
%      Simulink model name string to apply GD on (the model is passed to
%      "linearize" command). It is initialized as an empty string.
% red_rate = 5;
%       The rate of decreasing GD_step if no improvement was achieved
% inc_rate = 2;
%       The rate of increasing GD_step in case of improvement
% linearized_timed_step = 0.5;
%       The time step between samples for linearization

% See also: SA_Taliro, staliro_options, Apply_Opt_GD_default, GdDoc

% (C) 2019, Shakiba Yaghoubi, Arizona State University
    
    properties
        GD_func = 'Apply_Opt_GD_default';
        no_suc_TH = 2;  % Only for SA
        no_dec_TH = 10;
        init_GD_step = 10;
        min_GD_step = 0.01;
        model = '';
        red_rate = 5;
        inc_rate = 2;
        linearized_timed_step = 0.5;
    end
    
    methods
        function obj = GD_parameters(varargin)
            if nargin>0
                error(' GD_parameters : Please access directly the properties of the object.')
            end
        end
    end
    
end

