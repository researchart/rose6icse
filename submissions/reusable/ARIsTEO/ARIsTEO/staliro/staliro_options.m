% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef staliro_options
% Class definition for the S-Taliro options
%
% opt = staliro_options;
%
% The above function call sets the default values for the class properties. 
% For a detailed description of each property open the <a href="matlab: doc staliro_options">staliro_options help file</a>.
%
% To change the default values to user-specified values use the default
% object already created to specify the properties.
%
% E.g.: to change the optimization_solver to Ant Colony Optimization type
% opt.optimization_solver = 'ACO_Taliro';
%
% NOTE: For more information on properties, click on them. 
%
% See also: staliro, staliro_blackbox

% (C) 2010, Yashwanth Annapureddy, Arizona State University
% (C) 2010, Georgios Fainekos, Arizona State University
% (C) 2012, Bardh Hoxha, Arizona State University
% (C) 2015, Adel Dokhanchi, Arizona State University

    properties(Dependent)
        % Choose optimization solver for the test generation.
		%
		%   Default value : opt.optimization_solver = 'SA_Taliro';
		%
        %   Each optimization algorithm must have its own class of parameters. 
		%
        %   The user can define his/her own optimization function. The current 
		%   options which are available with the S-Taliro distribution are:
        %       1. <a href="matlab: doc SA_Taliro">SA_Taliro</a>: Simulated Annealing with hit and run Monte Carlo sampling. 
        %                For its parameters see <a href="matlab: doc SA_Taliro_parameters">SA_Taliro_parameters</a>.
        %       2. <a href="matlab: doc ACO_Taliro">ACO_Taliro</a>: Extended Ant Colony Optimization. 
		%                For its parameters see <a href="matlab: doc ACO_Taliro_parameters">ACO_Taliro_parameters</a>.
        %       3. <a href="matlab: doc GA_Taliro">GA_Taliro</a>: Genetic Algorithms. 
		%                The Genetic Algorithm toolbox by Mathworks must be installed.
        %                For its parameters see <a href="matlab: doc GA_Taliro_parameters">GA_Taliro_parameters</a>.		
        %       4. <a href="matlab: doc UR_Taliro">UR_Taliro</a>: Uniform random sampling of the parameter space.
        %                For its parameters see <a href="matlab: doc UR_Taliro_parameters">UR_Taliro_parameters</a>.		
        %       5. <a href="matlab: doc CE_Taliro">CE_Taliro</a>: Cross entropy method for sampling.
        %                For its parameters see <a href="matlab: doc CE_Taliro_parameters">CE_Taliro_parameters</a>.		
        %       6. <a href="matlab: doc MS_Taliro">MS_Taliro</a>: Performs Multi-Start with local gradient descent starting 
		%                from each point. Currenlty, MS_Taliro works only with hybrid automata 
		%                of type <a href="matlab: doc hautomaton">hautomaton</a>.
        %                For its parameters see <a href="matlab: doc MS_Taliro_parameters">MS_Taliro_parameters</a>.		
        %       7. <a href="matlab: doc RGDA_Taliro">RGDA_Taliro</a>: Robustness Guided Parameter Falsification Domain Algorithm 1.
        %                For its parameters see <a href="matlab: doc RGDA_Taliro_parameters">RGDA_Taliro_parameters</a>.		
        %       8. <a href="matlab: doc SDA_Taliro">SDA_Taliro</a>: Robustness Guided Parameter Falsification Domain Algorithm 2.
        %                For its parameters see <a href="matlab: doc SDA_Taliro_parameters">SDA_Taliro_parameters</a>.		
        %       9. <a href="matlab: doc SA_Cold_Stoch">SA_Cold_Stoch</a>: Simulated Annealing with hit and run Monte Carlo sampling.
		%                This option is suitable for stochastic CPS models. SA_Cold_Stoch 
		%                calculates the minimum expected robustness value for a stochastic  
		%                model and the corresponding sample that produces the expected 
		%                robustness value.
        %                For its parameters see <a href="matlab: doc SA_Cold_Stoch_parameters">SA_Cold_Stoch_parameters</a>.
		%
		%   Note: Some of the provided algorithms are in a beta release. For example
		%         they may not return history data. It is advised that before you use 
        %         each option, you should read the corresponding help file. In addition,
        %         some algorithms cannot be used directly with staliro, but only with
        %         derivatives of staliro.		
		%
		%   If you would like to utilize your own optimization solver, then you 
		%   may define a custom optimization function with a name defined as you like 
		%   and with the following interface: 
		%		[run, history] = YourFunctionName(inpRanges, opt)  
        %   See <a href="matlab: open optimization\readme.txt">optimization\readme.txt</a> for further instructions on how to write a  
        %   wrapper for your own optimization function.
		%
		%   Important: Each optimization algorithm has an accompanying parameters class
        %              which is named X_parameters where X is the name of the m-file  
        %              implementing the optimization algorithm. For example,  
        %              see <a href="matlab: doc SA_Taliro_parameters">SA_Taliro_parameters</a> for the available options for SA_Taliro.
        %
        %   All the optimization algorithms can be found in the directory "optimization".
        optimization_solver;
        
        % Set the optimization parameters for the optimization algorithm. 
		% This property should not be modified by the user. This property is
		% automatically set when the optimization solver is chosen through the
		% property <a href="matlab: doc staliro_options.optimization_solver">optimization_solver</a>
        optim_params;
    end
	
    properties(Access=private)
        priv_optimization_solver = 'SA_Taliro';
        priv_optim_params = SA_Taliro_parameters;
    end    
    
	properties
        % Set the ODE solver for model simulation.
        % 
		%   Default option: ode_solver = 'default';
		%
        %   This option selects the ODE solver. The default option is 'ode45'.
        %   It is recommended that the option is set to 'default' for Simulink
        %   models. For Simulink models, the default option uses the default
        %   solver inside the Simulink model.
        ode_solver = 'default';
        
        % Choose whether to run 'falsification' or 'minimization' of robustness.
		% 
		%   Default option : falsification = 1;
		%
        %   If this option is set to true (1), then S-Taliro performs
        %   falsification. That is, it stops executing when a trajectory of
        %   negative robustness value is detected.
		%
        %   If this option is set to false (0), then S-Taliro performs
        %   minimization. That is, even if a falsifying trajectory is found,
        %   S-Taliro continues the search for the worst possible behavior.
        falsification = 1;
        
        % Choose interpolation function for input signals.
		%
		%   Default option : interpolationtype = {'pchip'};
		%
        %   The methods for interpolation functions are:
        %
        %       * any method provided by the Matlab function <a href="matlab: doc interp1">interp1</a>. 
		%         Examples of supported methods: 'linear', 'pchip', 'spline'
        %
        %       * 'pconst' for piecewise constant signals 
        %
		%       * 'const' for constant signals (only one control point must be specified)
        %
		%       * 'bool' for Boolean signals that take values from the set {0,1}
        %
		%       * 'UR' for a white noise signal within the input bounds and expected value the middle  
        %          point of the input range (only one control point must be specified) 
        %
		%       * A function pointer to a function with one of the following interfaces:
		%           1. y = FunctionName(x,timeStamps)
		%              where 
		%                 * x are the values of the search variables that parameterize the signal 
		%                   (these are the values determined by S-Taliro)
        %                 * timeStamps is a vector containing the times at which we need to know 
        %                   the value of the signal y.
        %              For an example on how to create a custom interpolation function see
        %              the m-function <a href="matlab: doc StepInputSignal">StepInputSignal.m</a>
        %           2. y = FunctionName(x,t,timeStamps)	
		%              where 
		%                 * x and timeStamps are defined as above
		%                 * t is a vector containing the times which correspond to the 
		%                   parameter values in x. This is required in case the variable times 
		%                   option of S-Taliro is enabled. See <a href="matlab: doc staliro_options.varying_cp_times">staliro_options.varying_cp_times</a>
        %
        %       * A cell pair of a signal array and an interpolation method from above. 
        %           * The signal array defines a prefix for the signal using numerical data. The 
        %             first column contains the time stamps for the signal values. Columns 2 and
        %             beyond contains the signal values.
        %         The staliro engine generates signals using the prefix data concatenated with 
        %         signals interpolated using the search control points. 
        %         Examples:
        %               tt1 = 0:0.05:5;
        %               xt1a = 0.2*tt1;
        %               xt1b = 0.2*tt1;
        %               tt2 = 0:0.05:2;
        %               xt2 = 0.5*tt2;
        %               opt.interpolationtype = {{[tt1',xt1a'],'linear'}}
        %               % two signals using different prefix and interpolation functions 
        %               opt.interpolationtype = {{[tt1',xt1a'],'linear'},{[tt2',xt2'],'pconst'}}
        %               % this is the case when multiple signals are interpolated using the same function  
        %               opt.interpolationtype = {{[tt1',xt1a',xt1b'],'linear'}} 
        %
        %   One interpolation function must be provided for each input signal. For
        %   example if input signal 1 is a piecewise constant signal and input
        %   signal 2 is a piecewise linear signal. Then,
        %           opt.interpolationtype = {'pconst'; 'linear'};
        %
        %   Notes:
        %   * If there are multiple input signals and all of them are using the
        %     same interpolation function, then only one interpolation function
        %     need to be specified. For example, if there are 3 input signals all
        %     of which are piecewise linear functions, then
        %           opt.interpolationtype = {'linear'};
		%   * The interpolation function will be sampled with step size <a href="matlab: doc staliro_options.SampTime">staliro_options.SampTime</a>
        interpolationtype = {'pchip'};

        % Select the sampling interval for the input signal interpolation.
		%
		%   Default option : SampTime = .05;
		%
        %   The sampling interval rate for creating input signals using the 
        %   interpolation function from <a href="matlab: doc staliro_options.interpolationtype">staliro_options.interpolationtype</a>.
        SampTime = .05;
		
        % Is the model a Blackbox?
		%
		%   Default option : black_box = 0;
		%
        %   (This option is maintained for backwards compatibility with older staliro 
        %	versions)
		%
        %   If the model is a function pointer and the 'black_box' is set to 0,
        %   then the function is passed to the ODE solver indicated by the option
        %   'ode_solver'.
        %
        %   If the model is a function pointer and the 'black_box' is set to 1,
        %   then it is assumed that the model will be given the initial conditions, 
        %   total simulation time, time stamps for input signal sampling, and the
        %   input signals, and it will output the simulation time stamps, the state 
        %   trajectory, the output trajectory and, optionally, the graph and guards 
        %   depending on the option 'taliro_metric' that will be used. That is, S-Taliro 
        %   will treat the input function as a black box.
        %
        %   A blackbox function should obey the following interface:
        %
        %   Interface:
        %       [T X Y L CLG GRD] = function(X0,ET,TS,U)
        %   Inputs:
        %       X0 - the initial conditions as a column vector.
        %       ET - the end time for the simulation. It is assumed that the start
        %            time is zero.
        %       TS - time stamps that correspond to the sampling instances for the
        %            input signals in U. This is optional if no input signals
        %            are required.
        %       U  - the input signals. This is an array where each column
        %            corresponds to a different signal and each row to time 
        %            instance that corresponds to TS. This is optional if no input 
        %            signals are required.
        %   Outputs:
        %       T  - the timestamps of the output trajectories.
        %       X  - the state trajectory as an array where each column corresponds 
        %			 to a different state variable. 
        %       Y  - the output trajectory as an array where each column  
        %		     corresponds to a different output variable. 
        %       L  - the location/mode trajectory as an array where each column 
        % 			 corresponds to a different stateflow chart or finite state 
        %			 machine (FSM). 
        %     CLG -  the graph that corresponds to the finite state machine of the 
        %			 system. This should be a cell vector with the adjacency list 
        %			 of the graph. 
        %		     If there are multiple FSM, then G should be cell vector where 
        %			 each entry is a cell vector with the adjacency list for each 
        % 			 FSM. In this case, the length of G should match the number of 
        %			 columns of L.
        %			 Example: We will set a graph with 2 FSM with 2 states each:
        %			 	FSM = {[2],[1]}; % State 1 transitions to 2 and vice versa.
        %				CLG{1} = FSM;
        %				CLG{2} = FSM;
        %			 This is required when hybrid distance metrics are used.
        %      GRD - the guards that enable the switch from one location to the 
        %			 next. In case of a single FSM, this is a structure array with  
        %			 the following entries:
        %				GRD(i,j).A; GRD(i,j).b
        %			 A transition from state i to state j is enabled if the current 
        %			 state is x and GRD(i,j).A*x<=GRD(i,j).b.
        %			 The guards can be defined over the space 'X' or the space 'Y'.
        %			 If there are multiple FSM, then GRD should be a cell vector
        %			 where each entry should be structure array as defined above.
        %
        %   Remark:
        %   This option could be used for hardware-in-the-loop (HIL) testing.
        black_box = 0;
        
        % Set the total number of runs (experiments) to be executed.
		% 
		%   Default option : runs = 1;
		%
        %	When benchmarking a new algorithm, you may want to execute the same 
        %	problem setup multiple times. Set runs to any number that you would
        %	like for the staliro run to be repeated. Typically, for statistically
        %   significant results 100 runs should be executed.		
        runs = 1;
        
        % Select the space for which the specifications are going to be checked against.
		%
		%   Default option : spec_space = 'Y';
		%
        %   In case of Simulink of Blackbox models, the specifications can be over trajectories
        %   of the state variables of the system, option 'X', or over the output signals of the 
		%   system, option 'Y'.
        spec_space = 'Y';
        
        % Select the output signals (ports) that correspond to finite state machine (FSM) traces (trajectories).
		%
		%   Default option : loc_traj = 'none';
		%
        %   In case of hybrid system trajectories generated by a model, the 'loc_traj'
        %   option is used to define which output signal corresponds to the location trace.
        %   Options:
        %      'none'         - (default) the output signals do not contain a location (mode) trace.
        %      'end'          - the location trace is in the last output port
        %      integer vector - if the location traces are outputted from other ports, 
        %                       then 'loc_traj' should contain the corresponding port or 
		%						dimension numbers.
        loc_traj = 'none';
     
        
        % Set the Simulink model output data to a single or multiple variables.
		%
		%   Default option : SimulinkSingleOutput = 0;
		%
        %   Set the Simulink model to output data in a single variable (1) or in
        %   multiple variables (0). This is a Simulation option controlled only
        %   through the GUI interface of Simulink models. Thus, it must be set by
        %   the user accordingly to what is selected in the model. Usually,
        %   the default option for the 'sim' command is to output data in multiple
        %   variables even if structures are used.
        SimulinkSingleOutput = 0;
        
        % Choose whether to display information while the optimization algorithm runs.
		%
		%   Default option : dispinfo = 1;
		%
        %   Display information as S-Taliro runs, i.e., current best value, current
        %   run and total run time of each run.
        dispinfo = 1;
        
        % Choose whether to plot results.
		%
		%   Default option : plot = 0;
		%
		%   Certain staliro functions can plot results. For example, the falsification domain 
        %   (Pareto front) identified through parameter mining is better understood through 
		%   plotting of the results in 2D.
		%
        %   Set to 1 to plot results or to 0 to not plot results.
        plot = 0;
        
        % Choose whether to save intermediate results on the hard disk.
		%
		%   Default option : save_intermediate_results = 0;
		%
        %   Set to 1 to have staliro save the results of each run as soon as
        %   it's done. This option is useful for long runs: if you decide to kill 
        %   the job halfway, you have something saved.
        save_intermediate_results = 0;
        
        % Choose the file name where to save the intermediate results.
		%
		%   Default option : save_intermediate_results_varname = 'default';
		% 
        %   This option sets the name of the variable to which the intermediate
        %   results will be saved. If the model is a Simulink model with name 'mdl' 
		%   and the option is set to 'default', then the results will be saved in the 
		%   filename 'mdl_results.mat'. Otherwise, the string stored in the property
		%   save_intermediate_results_varname will be used.
        save_intermediate_results_varname = 'default';
        
        % Choose whether to use a hybrid distance metric in the specification robustness computations.
		%
		%   Default option : taliro_metric = 'none';
		%
        %   The type of temporal logic metric to be used. Options:
        %    'none'       - (default) only the continuous space is considered. Any
        %                   location information on the predicates is ignored.
        %    'hybrid_inf' - The robustness metric considers the path distance
        %                   between control locations and the euclidean space
        %                   distance.
        %    'hybrid'     - The robustness metric considers also the distance to
        %                   the guards that enable a transition on the hybrid
        %                   system.
		% 
		%   The theory behind each option is explained in the technical report:
		%   <a href="matlab: web('http://www.public.asu.edu/~gfaineko/pub/tech11_sa_fals.pdf')">Probabilistic Temporal Logic Falsification of Cyber-Physical Systems</a>
        taliro_metric = 'none';
        
        % Set whether hybrid distance values will be mapped on the real line.
		%
		%   Default option : map2line = 1;
		%
        %   When using a standard optimization algorithm with the hybrid distance
        %   values, then we need to map the hybrid distance values on the real line using 
        %   the <a href="matlab: web('https://en.wikipedia.org/wiki/Logistic_function')">inverse logit function</a> (see parameter <a href="matlab: doc staliro_options.rob_scale">rob_scale</a>). Setting map2line to 0
        %   will utilize more complicated optimization algorithms that will attempt
        %   to minimize directly the hybrid metric. 
		%  
		%   If an optimization algorithm does not support the hybrid metric, then an 
		%   error will be issued.
        map2line = 1;
        
        % Set the scaling factor for <a href="matlab: doc staliro_options.map2line">map2line</a>.
		%
		%   Default option : rob_scale = 100;
		%   
        %   For using a standard optimization algorithm with hybrid distance
        %   values, we are mapping the hybrid distances on the real line using the
        %   inverse logit function:
        %          rob = h.dl + 2*(2*exp(h.ds/alpha)/(1+exp(h.ds/alpha))-1)
        %   where alpha is a scaling factor and h the hybrid distance. If the scaling
        %   factor is not provided, then alpha = 100. The scaling factor depends on
        %   the application and it is important since a value of h.ds above 40 with
        %   alpha = 1 already gives the upper bound 1 for the inverse logit function.
        %   This implies that large range of robustness values might be mapped to
        %   the same number. In turn, this will slow down the convergence rate of the 
		%   optimization algorithm.
        rob_scale = 100;
        
        % Set the offset value in the cost function of the parameter mining algorithm.
		%
		%   Default option : RobustnessOffset = [];
		%
        %	This property is used in parameter estimation. Currently, it is 
        %	recommended to not change this option. This is automatically set by the 
		%   search algorithm.
        RobustnessOffset = [];
        
        % Set the function for temporal logic robustness computation.
		%
		%   Default option : taliro = 'dp_taliro';
		%   
        %	The temporal logic robustness computation engine you would like to 
        %	use. The supported options are:
        %      * <a href="matlab: doc dp_taliro">dp_taliro</a>
        %      * <a href="matlab: doc dp_t_taliro">dp_t_taliro</a>
        %      * <a href="matlab: doc fw_taliro">fw_taliro</a> 
		%   
		%   You can also define your own cost function without considering the specification. 
		%   To utilize a custom cost function, the specification phi to staliro must be set 
		%   to empty, i.e., phi = [], and the custom function needs to be placed in a path 
		%   accessible by Matlab. The function needs to obey the following interface:
		%           rob = custom_cost( x, t, auxData )
		%   where 
		%      * x is the array containing the state trajectory 
		%      * t is the vector with the time stamps of the state trajecotry
		%      * auxData is a variable that can store any desired data and it set 
		%        through the staliro property <a href="matlab: doc staliro_options.customCostAuxData">customCostAuxData</a>.
		%      * rob is the computed robustness value
        taliro = 'dp_taliro';
        
        % Set the number of workers for parallel computation.
		%
		%   Default option : n_workers = 1;
		%
        %   Set the number of workers to be used by the stochastic optimizer. 
        %   Setting this option to 0 or 1 does not initialize a worker pool.
        %   For an integer n greater than 1, a parallel pool of n workers is 
        %   initialized. The default maximum number of workers allowed is the  
        %   number of cores on the local machine.
		%
		%   This option is highly recommended for test generation for stochastic models
		%   since for each input signal and initial conditions and parameters, multiple
		%   simulations must be executed in order to approximate the expected robustness
		%   value.
		%
		%   Some stochastic search algorithms are also inherently parallelizable. In 
		%   such cases, the overall runtime of the algorithm can be proportionally reduced  
		%   to the number of workers.
        n_workers = 1;
        
        % Choose whether the model under test is stochastic or not.
		%
		%   Default option : stochastic = 0;
		%
		%   Set (1) for stochastic models and (0) for deterministic models.
		%   
        %   Indicates whether the model (or system) is stochastic. If the system is
        %   stochastic and the number of workers n is greater than 1, then the
        %   system will be simulated n times for the same input and initial
        %   conditions. 
        stochastic = 0;
        
        % Set the options for the hybrid automaton simulator.
		%
		%   Default option : hasim_params = [1 0 0 0 0];
		% 
        %   See <a href="matlab: doc hasimulator">hasimulator</a> for details.
        hasim_params = [1 0 0 0 0];
        
        % Indicates whether the optimization algorithm will be solving a minimization or maximization problem.
		%
		%   Default option : optimization = 'min';
		%
		%   Options : 'min' or 'max'
		%
        %   Indicates whether the optimization is min or max. For falsification, we attempt to
        %   minimize the robustness value. In parameter mining, we solve min or max problems
        %   depending on the monotonicity of the formula.
		%
		%   This option is typically not modified by the user unless a custom cost function
		%   is utilized.
        optimization = 'min';
        
        % Set whether this is a specification parameter mining problem.
		%
		%   Default option : parameterEstimation = 0;
		%
        %   Indicates whether the problem is a parameter mining problem (1) or not (0). 
        parameterEstimation = 0;
        
        % Set whether <a href="matlab: doc dp_t_taliro">dp_t_taliro</a> metric will be utilizing past, future or both robustness values.
		%
		%   Default option : dp_t_taliro_direction = 'both';
		%  
        %   When using the <a href="matlab: doc dp_t_taliro">dp_t_taliro</a> metric, we can set the options for 
        %   'past', 'future', or 'both'
        dp_t_taliro_direction = 'both';
        
        % Set the seed for the pseudo-random number generator.
		%  
		%   Default option : seed = -1;
		%
        %   This option sets the seed for the random number generator. Two options are possible:
        %      1) -1 the random number generator is not modified
        %      2) A non-negative integer 
        %      3) A structure returned by the function "rng" storing the state of current settings of the  
		%         random number generator. See the documentation <a href="matlab: doc rng">rng</a>.
        %         This information is also stored in staliro results in the field "RandState" and can be 
        %         used for results reproducibility.
        %
        %   In older Matlab versions, it sets the seed for the random number stream 'mt19937ar'. 
        %   The seed should be a value a non-negative integer.
		%
		%   Important: When Matlab starts from the same seed, then the same sequence of random 
        %              numbers will be produced. This means that for the same problem we achieve
        %              reproducibility of the results. However,	if different experiments need to 
        %              performed on the same benchmark problem, then the initial seed needs to be 
		%              initially randomized.
        seed = -1;       
        
        % Choose which dimension of the state or output space should be considered for specification robustness.
		%
		%   Default option : dim_proj = [];
		% 
        %   Selects the dimensions of the output or state vector that taliro will work with.
		%   This option helps to reduce memory requirements for models with very large state
		%   or output spaces.
		%
        %   Example: your model has 4 outputs; however, you only want to consider outputs
        %   2 and 4. To do so, set opt.dim_proj = [2 4]; 
        dim_proj = [];
        
        % Select whether time points (or samples) in the trajectory should be ignored during specification robustness computations.
		%
		%   Default option : taliro_undersampling_factor = 1;
		%
		%   If the option is set to 1, then all the points of the trajectory will be used 
		%   for specification robustness computations. For any integer value n greater than 1,
		%   the robustness computation will be performed on every n time points of the 
		%   trajectory. This option is provided in order to speed up the robustness computation
		%   on system trajectories with very small integration step size.
        taliro_undersampling_factor = 1;
        
        % Select whether the time instants of the control points for the input signal parameterization are fixed or not.
		%
		%   Default option : varying_cp_times = 0; 
		%
        %   The following options are supported:
		%      0 : fixed equidistant distribution of time stamps depending on the number of control points 
		%          and the interpolation function.
		%      1 : variable time distribution for the control points. With this option the following constraints must be
        %          satisfied:
        %             * Each input signal should have the same number of control points
        %             * The time stamps of the corresponding control points are synchronized
		%      2 : variable time distribution for the control points where each control point is associated
		%          with a different time variable. This option provides more flexibility, but the search
		%          space is larger than option 1.
		% 
        %   Currently, not all the optimization engines support this feature. If the feature is not supported an error 
        %   message will be issued.
        varying_cp_times = 0;
        
        % Control the minimum distance between the time stamps of the control points when varying_cp_times==2
        %
		%   Default option : varying_cp_times_coeff = 1e-6;
        %
        % The value varying_cp_times_coeff is multiplied with the total simulation time to give the minimum 
        % time distance between control points. It should be a value less than 1.
        varying_cp_times_coeff = 1e-6;        
        
        % Select whether to normalize the temporal logic robustness values in the interval [0 1].
		%
		%   Default option : normalization = 0;
		%
        %   Set to 1 to scale the parameters to the unit square while conducting parameter estimation. 
		%   This option is useful when interested in using the same weight to all parameters in 
		%   specification parameter mining. 
		%   
		%   Note: Should not to be confused with the predicate normalization option which is supported 
		%         through the atomic proposition definition.
        normalization = 0;
        
        % Select the weight function for each parameter in a multi-parametric specification mining.
		%
		%   Default option : polarity_weight = 'norm';
		%
        %   Set to 'norm', 'max', 'min', function handle, or vector where each 
        %   column represents the weight for a parameter. The function handle 
        %   should output a scalar given a vector of parameters. The selection 
        %   will impact the robustness guided search for parameter estimation. 
        polarity_weight = 'norm';
        
        % Indicates whether the algorithm is in falsification stage when running parameter estimation.
		%
		%   Default option : param_est_fals_stage = 1;
		%
		%   This is an internal option and it should not be modified by the user.
        param_est_fals_stage = 1;
        
        % Select whether zero robustness is considered as a falsification or not.
		%
		%   Default option : fals_at_zero = 1;
		%
        %   The stochastic optimizer will terminate when robustness is 0 and return the falsifying  
        %   behavior when fals_at_zero is equal to 1. If the the property is set to 0, then the 
		%   robustness has to be strictly less than 0 to terminate the search process.
        fals_at_zero = 1;
        
        % Read only property - Do not modify
		%
		%   Default option : TotSimTime = [];
		%
        %   This is the total simulation time that is given as input to staliro.
        %   This is not set explicitly by the user, but it is set by staliro during
        %   initialization. This should be treated as a read-only property.
        TotSimTime = [];
        
		% Define constrained search spaces (polyhedral sets)
		% 
		%    Default option : search_space_constrained.constrained = false;
		%    
		%    If you want to define a convex search space different from a hypercube,
		%    then set the field constrained to 1. In this case, you can define a 
		%    search space of the form Ax<=b using the fields A_ineq and b_ineq in the 
		%    class staliro_options. If the set of initial conditions in staliro is also 
		%    defined, then the search space will be the intersection of the hypercube 
		%    and the set Ax<=b.
		%
		%    This option is optimization solver dependent and may not be supported by 
		%    all the optimization solvers.
        %
        %    Note: if there are fixed initial conditions defined by setting the upper and 
        %    lower bounds to be the equal, then these must not be included as search
        %    variables in the constraints.
		search_space_constrained = struct('constrained',false,'A_ineq',[],'b_ineq',[]);
        
        % Provide data to your own cost function for the optimization.
		%
		%   Default option : customCostAuxData = [];
		%
        %   This option lets the user provide any data needed in their own custom cost
        %   function. The cost function replaces the 'taliro' family of cost functions.
        customCostAuxData = []; 
		
        % Set the properties and options for coverage based testing in S-Taliro
		% 
		%   Default option : StrlCov_params = StrlCov_parameters;
		%
        %   Structural Coverage toolbox. See <a href="matlab: doc StrlCov_parameters">StrlCov_parameters</a> for details on the available options.
        StrlCov_params = StrlCov_parameters;
        
        % Specify the indices for fixed and searchable initial conditions
        % 
		% Default value: X0Fixed.fixed = false;
		%
        % S-Taliro assumes that all the variables in the set of initial conditions  
        % are search variables. If this is not the case, then this option can be used 
        % to declare fixed values for some initial conditions.
		%
		% If you would like to specify that some variables should be fixed, then 
		%    1) Set X0Fixed.fixed to true
		%    2) Specify the indices in X0Fixed.idx_fixed
		%    3) Specify the values in X0Fixed.values
		% The length of the fields idx_fixed and values must be the same.
        % 
        % Remark: If the upper and lower bounds of some variables are the same, then 
        % these are automatically set as fixed variables. 
        X0Fixed = struct('fixed',false,'idx_fixed',[],'idx_search',[],'values',[]);

        % Specify the STL/MITL Debugging and Vacuity Aware Falsification parameters
        % 
		%   Default option : vacuity_param = vacuity_parameters;
		%   
        %   For more information about vacuity_parameters class type >> help vacuity_parameters 
        vacuity_param = vacuity_parameters;

    end
    
    methods
        
        function obj = staliro_options(varargin)
            if nargin>0
                error(' staliro_options: Please access directly the properties of the object.')
            end
        end
            
    end
    
    % Set/Get methods for access control
    % See http://www.mathworks.com/help/matlab/matlab_oop/property-access-methods.html
    methods
        
        function str_optim = get.optimization_solver(obj)
            str_optim = obj.priv_optimization_solver;
        end

        function obj = set.optimization_solver(obj,value)
            % When the user changes optimization method, then update the
            % optimizer parameters
            assert(exist(value,'file')==2, ' staliro_options : The selected optimizer does not exist!');
            str_file_name = [value,'_parameters'];
            assert(exist(str_file_name,'file')==2, ' staliro_options : The selected optimizer does not have a class for parameters! See optimization\readme.txt');
            obj.priv_optimization_solver = value;
            % if the user defines the same optimization method keep the
            % parameters the same, else instantiate the new parameters
            if ~isa(obj.priv_optim_params,str_file_name)
                obj.priv_optim_params = eval(str_file_name);
            end
        end

        function params = get.optim_params(obj)
            params = obj.priv_optim_params;
        end

        function obj = set.optim_params(obj,value)
            % When the user changes optimization method, then update the
            % optimizer parameters
            assert(isa(obj.priv_optim_params,class(value)), ' staliro_options : The optimization parameters type does not match the selected optimization method! Please first update the optimization method.');
            obj.priv_optim_params = value;
        end
        
        function obj = set.interpolationtype(obj,value)
            % User can specify several interpolation methods for each
            % signal
            assert(iscell(value), ' staliro_options : interpolationtype must be a cell');
            obj.interpolationtype = value;
        end
        
        function obj = set.SampTime(obj,value)
            assert(value > 0, ' staliro_options : SampTime must be positive');
            obj.SampTime = value;
        end
        
        function obj = set.rob_scale(obj,value)
            assert(value > 0, ' staliro_options : rob_scale must be positive');
            obj.rob_scale = value;
        end
        
        function obj = set.spec_space(obj,value)
            assert(strcmp(value,'X') || strcmp(value,'Y'), ' staliro_options : spec_space must be either X (for state-space) or Y (for output space)');
            obj.spec_space = value;
        end
        
        function obj = set.varying_cp_times(obj,value)
            assert((value==0 || value==1 || value==2), ' staliro_options : varying_cp_times must be 0, 1, or 2');
            obj.varying_cp_times = value;
        end
     
        function obj = set.varying_cp_times_coeff(obj,value)
            assert((0<value && value<1), ' staliro_options : varying_cp_times_coeff should be between 0 and 1');
            obj.varying_cp_times_coeff = value;
        end
        
    end
end