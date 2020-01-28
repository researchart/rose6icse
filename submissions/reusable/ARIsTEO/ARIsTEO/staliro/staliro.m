% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% S-TaLiRo
%		
%  Systems' TemporAl LogIc RObustness : A toolbox to perform Temporal 
%  Logic Falsification and Parameter mining for Cyber-Physical Systems 
%  (models, software or hardware in the loop)
%
% USAGE:
%
% [results, history, opt] =
%    staliro(model,init_cond,input_range,cp_array,phi,preds,TotSimTime,opt)
%
% DESCRIPTION :
%
%   S-Taliro performs temporal logic falsification and parameter mining  
%   for hybrid systems models. The input model can be in several forms, 
%   such as a Simulink model or an m-function, and the specification  
%   can be a Signal Temporal Logic (STL) formula which is encoded using  
%   a Metric Temporal Logic (MTL) formula.
%
% INPUTS :
%
%   - model : can be of type:
%
%       * function handle : 
%         It represents a pointer to a function which will be numerically 
%         integrated using an ode solver (the default solver is ode45). 
%         The solver can be changed through the option
%                   staliro_options.ode_solver
%         See documentation: <a href="matlab: doc staliro_options.ode_solver">staliro_options.ode_solver</a>
%
%       * Blackbox class object : 
%         The user provides a function which returns the system behavior 
%         based on given inputs and initial conditions. For example, this 
%         option can be used when the system simulator is external to 
%         Matlab. Please refer tp the staliro_blackbox help file.
%         See documentation: <a href="matlab: doc staliro_blackbox">staliro_blackbox</a>
%
%       * string : 
%         It should be the name of the Simulink model to be simulated.
%
%       * hautomaton :
%         A hybrid automaton of the class hautomaton.
%         See documentation: <a href="matlab: doc hautomaton">hautomaton</a>
%
%       * ss or dss :
%         A (descriptor) state-space model (see help file of ss or dss).
%         If the ss or dss models are discrete time models, then the 
%         sampling time should match the sampling time for the input 
%         signals (see staliro_options.SampTime). If they are not the same,
%         then an error will be issued.
%         See documentation: <a href="matlab: doc ss">ss</a>, <a href="matlab: doc dss">dss</a>, <a href="matlab: doc staliro_options.SampTime">staliro_options.SampTime</a>
%
%       Examples: 
%
%           % Providing directly a function that depends on state and time
%           model = @(t,x) [x(1) - x(2) + 0.1*t; ...
%                   x(2) * cos(2*pi*x(2)) - x(1)*sin(2*pi*x(1)) + 0.1 * t];
%
%           % Just an empty Blackbox object
%           model = staliro_blackbox; 
%           
%           % For other blackbox examples see the demos in demos folder:
%           staliro_demo_sa_simpleODE_param.m
%           staliro_demo_autotrans_02.m
%           staliro_demo_autotrans_03.m
% 
%           % Simulink model under demos\SystemModelsAndData
%           model = 'SimpleODEwithInp'; 
%
%           % Hybrid automaton example (demo staliro_navbench_demo.m)
%           model = navbench_hautomaton(1,init,A);
%
%   - init_cond : a hyper-rectangle that holds the range of the initial 
%       conditions (or more generally, constant parameters) and it should be a 
%       Matlab n x 2 array, where 
%			n is the size of the vector of initial conditions.
%		In the case of a Simulink model or a Blackbox model:
%			The array can be empty indicating no search over initial conditions 
%			or constant parameters. For Simulink models in particular, an empty 
%			array for initial conditions implies that the initial conditions in
%			the Simulink model will be used. 
%
%       Format: [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_n UpperBound_n];
%
%       Examples: 
%        % A set of initial conditions for a 3D system
%        init_cond = [3 6; 7 8; 9 12]; 
%        % An empty set in case the initial conditions in the model should be 
%        % used
%        init_cond = [];
%
%       Additional constraints on the initial condition search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%
%   - input_range : 
%       The constraints for the parameterization of the input signal space.
%       The following options are supported:
%
%          * an empty array : no input signals.
%              % Example when no input signals are present
%              input_range = [];
%
%          * a hyper-rectangle that holds the range of possible values for 
%            the input signals. This is a Matlab m x 2 array, where m is the  
%            number of inputs to the model. Format:
%               [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_m UpperBound_m];
%            Examples: 
%              % Example for two input signals (for example for a Simulink model 
%              % with two input ports)
%              input_range = [5.6 7.8; 8 12]; 
%
%          * a cell vector. This is a more advanced option. Each input signal is 
%            parameterized using a number of parameters. Each parameter can 
%            range within a specific interval. The cell vector contains the
%            ranges of the parameters for each input signal. That is,
%                { [p_11_min p_11_max; ...; p_1n1_min p_1n1_max];
%                                    ...
%                  [p_m1_min p_m1_max; ...; p_1nm_min p_1nm_max]}
%            where m is the number of input signals and n1 ... nm is the number
%                  of parameters (control points) for each input signal.
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%       Additional constraints on the input signal search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%
%   - cp_array : contains the control points that parameterize each input 
%       signal. It should be a vector (1 x m array) and its length must be equal 
%       to the number of inputs to the system. Each element in the vector 
%       indicates how many control points each signal will have. 
%
%       Specific cases:
%
%       * If the signals generated using interpolation between the control  
%         points, e.g., piece-wise linear or splines (for more options see 
%         <a href="matlab: doc staliro_options.interpolationtype">staliro_options.interpolationtype</a>): 
%		  
%         Initially, the control points are equally distributed over 
%         the time duration of the simulation. The time coordinate of the 
%         control points will remain constant unless the option
%
%					<a href="matlab: doc staliro_options.varying_cp_times">staliro_options.varying_cp_times</a>
%
%         is set (see the staliro_options help file for further instructions and 
%         restrictions). The time coordinate of the first and last control 
%         points always remains fixed.
%
%         Example: 
%           cp_array = [1];
%               indicates 1 control point for only 1 input signal to the model.
%               One control point can only be used with piecewise constant 
%               signals. If we assume that the total simulation time is 6 time 
%               units and the input range is [0 2], then the input signal will 
%               be:
%                  for all time t in [0,6] u(t) = const with const in [0,2] 						
%
%           cp_array = [4];
%               indicates 4 control points for only 1 input signal to the model.
%               If we assume that the total simulation time is 6 time units, 
%               then the initial distribution of the control points will be:
%                            0   2   4   6
%
%           cp_array = [10 14];
%               indicates 10 control points for the 1st input signal and 
%               14 for the second input.
%
%      * If the input_range is a cell vector, then the input range for each
%        control point variable is explicitly set. Therefore, we can
%        extract the number of control points from the number of
%        constraints. In this case, the cp_array should be set to emptyset.
%
%           cp_array = [];
%
%   - phi : The formula to falsify. It should be a string. For the syntax of MTL 
%       formulas type "help dp_taliro" (or see staliro_options.taliro for other
%       supported options depending on the temporal logic robustness toolbox 
%       that you will be using).
%                               
%       Example: 
%           phi = '!<>_[3.5,4.0] b)'
%
%       Note: phi can be empty in case the model is a hybrid automaton 
%       object. In this case, an unsafe set must be provided in the hybrid
%       automaton.
%
%   - preds : contains the mapping of the atomic propositions in the formula to
%       predicates over the state space or the output space of the model. For 
%       help defining predicate mappings type "help dp_taliro" (or see 
%       staliro_options.taliro for other supported options depending on the 
%       temporal logic robustness toolbox that you will be using).
%
%       In case of parameter mining:
%           If staliro is run for specification parameter mining, then set the 
%           staliro option parameterEstimation to 1 (the default value is 0):
%               opt.parameterEstimation = 1;
%           and read the instructions under staliro_options.parameterEstimation 
%           on how to define the mapping of the atomic propositions.	
%
%   - TotSimTime : total simulation time.
%
%   - opt : s-taliro options. opt should be of type "staliro_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change S-Taliro options, 
%       see the staliro_options help file for each desired property.
%
% OUTPUTS
%   - results: a structure with the following fields
%
%       * run: a structure array that contains the results of each run of 
%           the stochastic optimization algorithm. The structure has the
%           following fields:
%               bestRob : The best (min or max) robustness value found
%               bestSample : The sample in the search space that generated 
%                   the trace with the best robustness value. 
%               nTests: number of tests performed (this is needed if 
%                   falsification rather than optimization is performed. See 
%					staliro_options.falsification for more information).
%               bestCost: Best cost value. bestCost and bestRob are the
%                   same for falsification problems. bestCost and bestRob
%                   are different for parameter estimation problems. The
%                   best robustness found is always stored in bestRob.
%               paramVal: Best parameter value. This is used only in 
%                   parameter mining or query problems. 
%					Important: This is valid if only if bestRob is negative.
%               falsified: Indicates whether a falsification occurred. This
%                   is used if a stochastic optimization algorithm does not
%                   return the minimum robustness value found.
%               time: The total running time of each run
%
%       * optRobIndex: stores the index of the run that contains the best 
%			(optimal) robustness value out of all runs.
%
%       * optParamValIndex: stores the index of the run that contains the 
%			optimal parameter value.
%
%		* polarity: indicates whether the specification has positive (increasing)
%         or negative (decreasing) robustness monotonicity with respect to
%         the parameters.
%
%       * RandState: it stores information about the state of the random
%         number generator when staliro starts. See staliro_options for
%         further details. Documentation: <a href="matlab: doc staliro_options.seed">staliro_options.seed</a>
%
%   - history: a vector structure equal in length to the runs (experiments) 
%		executed. It contains the following fields for each run:
%       * rob: all the robustness values computed for each test (simulation)
%       * samples: all the samples generated for each test (simulation)
%       * cost: all the cost function values computed for each test (simulation).
%           This is the same with robustness values only in the case
%           of falsification.
%
%   - opt: when using structural coverage, we need to extract information
%     regarding the number of locations or modes of the hybrid model.
%     In the current version of staliro this iformation is stored in
%     the staliro_options object and may need to be used by the function 
%     calling staliro.
%           TODO: This will be problematic in concurrent execution.
%                 Fix in a later version.
%		
% Please send reports for bugs and/or comments for improvements to 
%               fainekos @ gmail.com
% You can also submit tickets and code comments at Assembla.com:
%	https://app.assembla.com/spaces/s-taliro_public/wiki
%
% See also : staliro_options, SimulateModel, staliro_blackbox, dp_taliro, dp_t_taliro

% (C) 2010, Yashwanth Annapureddy, Arizona State University
% (C) 2010, Georgios Fainekos, Arizona State University
% (C) 2012, Bardh Hoxha, Arizona State University
% (C) 2013, Houssam Abbas, Arizona State University
% (C) 2013, Adel Dokhanchi, Arizona State University
% 
% This program is free software; you can redistribute it and/or modify   
% it under the terms of the GNU General Public License as published by   
% the Free Software Foundation; either version 2 of the License, or      
% (at your option) any later version.                                    
%                                                                        
% This program is distributed in the hope that it will be useful,        
% but WITHOUT ANY WARRANTY; without even the implied warranty of         
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          
% GNU General Public License for more details.                           
%                                                                        
% You should have received a copy of the GNU General Public License      
% along with this program; if not, write to the Free Software            
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [results, history, opt, sigData] ...
    = staliro(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, opt)

%% global declarations

global staliro_InputModel;
global staliro_InputModelType;
global staliro_mtlFormula;
global staliro_Predicate;
global staliro_InputBounds;
global staliro_SimulationTime;
global temp_ControlPoints;
global staliro_dimX;
global staliro_Polarity;
global staliro_Parameter;
global staliro_ParameterIndex;
global staliro_opt;
global staliro_parameter_list;
global staliro_inpRangeUnscaled;

global strlCov_locationHistory;

strlCov_locationHistory=cell(0);

% global single_sim_steps; % Not recommended for using parallel toolbox

%% Initialize inputs and check for errors in the input

% Check for the options
if(nargin<8) || isempty(opt)
    staliro_opt = staliro_options();
else
    if ~isa(opt,'staliro_options')
        error('S-Taliro: the options must be an staliro_options object')
    end
    staliro_opt = opt;
end

% Determine the model type and perform error checks
inputModelType = determine_model_type(model);
%%%%%%% added by Rahul  %%%%%%%%%%%%
% for backward compatability of Blackbox option.
% if user still using a Blackbox option then type cast model to Blackbox
% class by copying the "inputModel" variable to "model_fcnptr" field
if strcmp(inputModelType, 'function_handle') 
    if staliro_opt.black_box == 1
        %inputModelType = 'blackbox_model';
        temp_model_ptr = model;
        model = staliro_blackbox();
        model.model_fcnptr = temp_model_ptr;
    end
end
%%%%%%end of section -Rahul %%%%%%%%%%%%%%
if strcmp(inputModelType, 'ss')
    if model.TS>0 % model is discrete time => sampling rate for model and input signals must match
        if model.TS ~= staliro_opt.SampTime
            error(' staliro : the sampling rates of the model and the input signals do not match. Change the sampling rate for the input signals using the staliro option "SampTime".');
        end
    end
end

% If the seed for the random number generator is prespecified, set it
if isstruct(opt.seed)
    
    rng(opt.seed);
    results.RandState = opt.seed;
    
elseif opt.seed ~= -1
    
    if verLessThan('matlab', '7.12')
        stream = RandStream('mt19937ar','Seed',opt.seed);
        RandStream.setDefaultStream(stream);
        results.RandState = opt.seed;
    else
        rng(opt.seed);
        results.RandState = rng;
    end
    
else
    
    if verLessThan('matlab', '7.12')
        results.RandState = opt.seed;
    else
        results.RandState = rng;
    end
        
end

if ~((opt.taliro_undersampling_factor >=1) && (mod(opt.taliro_undersampling_factor,1)==0))
	error('S-Taliro: opt.taliro_undersampling_factor should be a positive integer')
end

% Check if model is a cell array, which would indicate performance testing
% needs to be performed

% Check the type of the model

if iscell(model)
    staliro_InputModelType{1} = determine_model_type(model{1});
    staliro_InputModel{1} = model{1};
    staliro_InputModelType{2} = determine_model_type(model{2});
    staliro_InputModel{2} = model{2};
    opt.optimization = 'max';
    if opt.falsification == 1
        error('S-Taliro: falsification should be set to 0 when doing conformance testing since the goal is to maximize the difference between the two models')
    end
else
    staliro_InputModelType = determine_model_type(model);
    staliro_InputModel = model;
end

% Check that the parallel computing toolbox is installed.
% Check that if the n_workers specified as an option is larger than the
% maximum allowed by the machine processor. If the number of workers
% set in opt.n_workers is different from the current state, change it. If
% opt.n_workers is set to 1 or 0 then close parallelization toolbox.

% check if matlab toolbox is installed
matlabVerData = ver;
% collect the names in a cell array
[installedToolboxes{1:length(matlabVerData)}] = deal(matlabVerData.Name);
% check 
tf = all(ismember('Parallel Computing Toolbox',installedToolboxes));

% check if toolbox is installed and licenced
if license('test','Distrib_Computing_Toolbox') && tf

    matVerLT2013b = verLessThan('matlab', '8.2.0.29');

    if opt.n_workers > feature('numCores')
        warning('S-Taliro: you requested more workers than are available on your machine')
        warning('S-Taliro: Starting the maximum number of workers')
        
        %matlabpool depreciated after 2013b, set to max number of cores available
        if matVerLT2013b
            matlabpool(feature('numCores'));
        else
            parpool(feature('numCores'));
        end

        opt.n_workers = feature('numCores');
        
    elseif opt.n_workers == 0 || opt.n_workers == 1

        %get number of running workers
        if matVerLT2013b
            runningWorkers = matlabpool('size');
        else
            poolInfo = gcp('nocreate');
            if(isempty(poolInfo))
                runningWorkers = 1;
            else
                runningWorkers = poolInfo.NumWorkers;
            end
        end

        %close running workers
        if runningWorkers ~= 0
            if matVerLT2013b
                matlabpool close;
            else
                poolObj = gcp('nocreate');
                delete(poolObj)
            end
        end 
    else

        if matVerLT2013b
            runningWorkers = matlabpool('size');
        else
            poolInfo = gcp('nocreate');
            if(isempty(poolInfo))
                runningWorkers = 1;
            else
                runningWorkers = poolInfo.NumWorkers;
            end
        end

        if runningWorkers ~= opt.n_workers && opt.n_workers > 1
            warning('S-Taliro: The number of workers requested is different from the worker pool in matlab. S-Taliro will automatically set the matlab pool of workers to n_workers.')
            
            if runningWorkers ~= 0
                if matVerLT2013b
                    matlabpool close; %#ok<*DPOOL>
                else
                    poolObj = gcp('nocreate');
                    delete(poolObj)
                end
            end
            
            if matVerLT2013b
                matlabpool(opt.n_workers);
            else
                parpool((opt.n_workers));
            end
        end
    end
else
    warning('S-TaLiRo: the Parallel Computing Toolbox is not installed or licensed. S-TaLiro cannot use parallelization.')
end

if ~iscell(staliro_InputModelType)
    if strcmp(staliro_InputModelType,'simulink') && (opt.n_workers > 1)
        warning('off','Simulink:Logging:LegacyModelDataLogsFormat');
        feval(staliro_InputModel, [],[],[],'compile')
        feval(staliro_InputModel, [],[],[],'term')
        warning('on','Simulink:Logging:LegacyModelDataLogsFormat');
    end
end

% MTL formula
staliro_mtlFormula = phi;
staliro_Predicate = preds;

staliro_Polarity = [];
staliro_Parameter = [];
staliro_ParameterIndex = [];

% Simulation time must be of type real
if isreal(TotSimTime)
    staliro_SimulationTime = TotSimTime;
    opt.TotSimTime = TotSimTime;
else
    error('S-Taliro: The simulation time is not of type real.');
end

global RUNSTATS;
RUNSTATS = RunStats(boolean(staliro_opt.n_workers > 1));

% If the metric in 'none', then make sure that the map2line is set to 0
if strcmp(staliro_opt.taliro_metric,'none') && staliro_opt.map2line==1
    staliro_opt.map2line = 0;
end

if staliro_opt.parameterEstimation > 0
    % Check whether the goal is parameter estimation
    [has_param, phi_polarity, list_param] = polarity(phi,preds);
    % temporary code until parameter estimation for more than one
    % parameter is supported
    if staliro_opt.parameterEstimation > 1
        error('S-Taliro: Parameter estimation for more than one parameter is not supported yet')
    end
    if has_param==0
        error('S-Taliro: Parameter estimation is requested, but the formula has no parameters. Please type "help polarity"')
    end
    if staliro_opt.falsification==1
        warning('S-Taliro: Parameter estimation is requested, but the "falsification" option is set to 1. Changing value to 0 ...')
        staliro_opt.falsification = 0;
    end
    staliro_Polarity = phi_polarity;
    if isequal(staliro_Polarity,-1)
        staliro_opt.optimization = 'min';
    elseif isequal(staliro_Polarity,1)
        staliro_opt.optimization = 'max';
    end
    ind = find(list_param>=2);
    staliro_parameter_list = list_param;
    staliro_Parameter = preds(ind);
    staliro_ParameterIndex = ind;
end
  
% Check to see if initial conditions have been declared correctly
[staliro_dimX,n1] = size(init_cond);
if (n1>2)
    error('S-Taliro: Initial conditions are not in the right format. Please look the help file.')
end
if ~isreal(init_cond)
    error('S-Taliro: initial conditions are not of type real.');
end

% Detect and remove fixed initial conditions
if ~staliro_opt.X0Fixed.fixed
    for i_ic = 1:staliro_dimX
        if init_cond(i_ic,1)==init_cond(i_ic,2)
            staliro_opt.X0Fixed.fixed = true;
            staliro_opt.X0Fixed.idx_fixed = [staliro_opt.X0Fixed.idx_fixed, i_ic];
            staliro_opt.X0Fixed.values = [staliro_opt.X0Fixed.values,init_cond(i_ic,1)];
        end
    end
end
if staliro_opt.X0Fixed.fixed
    staliro_opt.X0Fixed.idx_search = 1:staliro_dimX;
    staliro_opt.X0Fixed.idx_search(staliro_opt.X0Fixed.idx_fixed) = [];
    init_cond(staliro_opt.X0Fixed.idx_fixed,:) = [];
    staliro_dimX = size(init_cond,1);
    % Check if there are any polyhedral constraints and remove fixed variables 
    if staliro_opt.search_space_constrained.constrained
        staliro_opt.search_space_constrained.A_ineq(:,staliro_opt.X0Fixed.idx_fixed) = [];
    end
end

% Check to see if input ranges have been declared correctly
if isempty(init_cond) 
%     if ~strcmp(staliro_InputModelType,'simulink')
%         error('S-Taliro: Initial conditions might be omitted only when the model is a Simuliink model')
%     end
    if isempty(input_range)
        error('S-Taliro: The initial conditions and the input ranges cannot be empty at the same time')
    end
end
if ~isempty(input_range) && ((isnumeric(input_range) && size(input_range,2)~=2) || (iscell(input_range) && ~isvector(input_range)))
    error('S-Taliro: Input ranges are not in the right format. Please look the help file.')
end
if ~isreal(input_range) && ~iscell(input_range)
    error('S-Taliro: input ranges are not of type real');
end


% Verify that the inputs are in the right format
if ( (~iscell(input_range) && xor(isempty(input_range),isempty(cp_array))) || (iscell(input_range) && ~isempty(cp_array) && isempty(input_range)) )
    error('S-Taliro: if "input_range" is empty, then "cp_array" must be empty and vice versa. The only exception is when "input_range" is a cell array. See the help file!')
end
if ~isempty(cp_array)
    if (isreal(cp_array)) && isvector(cp_array)
        if size(input_range,1)~=length(cp_array)
            error('S-Taliro: The sizes of the input bounds and the control points do not match.')
        end
        for i=1:length(cp_array)
            if (cp_array(i) < 1)
                    error(['S-Taliro: The control points associated with every input must be at least 1. See input signal ',num2str(i),'.']);
            end
            if length(staliro_opt.interpolationtype)>1
                idx = i;
            else
                idx = 1;
            end
            if ~iscell(staliro_opt.interpolationtype{idx}) && ~strcmp(staliro_opt.interpolationtype{idx},'const') && (cp_array(i)==1)
                error(['S-Taliro: The interpolation function "',staliro_opt.interpolationtype{idx},'" for input signal ',num2str(i),' requires more than 1 control points.'])
            end
            if ~iscell(staliro_opt.interpolationtype{idx}) && strcmp(staliro_opt.interpolationtype{idx},'const') && (cp_array(i)~=1)
                error(['S-Taliro: Input signal ',num2str(i),' is set to be constant, but it is set to more than 1 control points. Change the corresponding control points to 1.'])
            end
        end
    else
        error('S-Taliro: cp_array must be a vector of type real');
    end
    if iscell(input_range) && ~isempty(input_range)
        % Confirm that the number of CP matches the ranges provided
        for j = 1:size(input_range,1)
            if ~isempty(cp_array)
                assert(size(input_range{j},1)==cp_array(j),['S-TaLiRo : The number of constraints in signal ',num2str(j),' does not match the specified number of control points.']);
            end
        end
    end
end

% Determine # of control points from the input_range
if iscell(input_range) && isempty(cp_array)
    for j = 1:size(input_range,1)
        cp_array(j) = size(input_range{j},1);
    end
end

% Check the input interpolation functions
if ((length(staliro_opt.interpolationtype)>1) && (length(cp_array)~=length(staliro_opt.interpolationtype))) 
    error('S-Taliro: The number of inputs are not equal to the number of interpolation types. Common error: Make sure you are using a cell array for the interpollation type.');
end

[m,dum] = size(input_range); %#ok<ASGLU>
temp_ControlPoints = zeros(1,m);
for j=1:m
   if(j==1)
      temp_ControlPoints(j) = cp_array(j);
   else
      temp_ControlPoints(j) = temp_ControlPoints(j-1) + cp_array(j);
   end
end

staliro_InputBounds = input_range;

% row size of input ranges must be equal to the column size of cp_array
[m1,dum] = size(input_range); %#ok<ASGLU>
n2 = length(cp_array);
if(m1~=n2)
    error('S-Taliro: Row size of input ranges must be equal to the column size of cp_array.');
end

% compute the total number of control points
input_count = size(init_cond,1);
for i=1:length(cp_array)
    input_count = input_count + cp_array(i);
end



InpRange = init_cond;

if iscell(input_range)
    for j = 1:n2
        InpRange = [InpRange; input_range{j}]; %#ok<AGROW>
    end
else
    for j = 1:n2
        InpRange = [InpRange; repmat(input_range(j,:),cp_array(j),1)]; %#ok<AGROW>
    end
end

if opt.varying_cp_times > 0
       
    for j = 1:n2
        if cp_array(j) <= 2
            error('S-Taliro: when using the control point variable times option, then the number of control points should be greater than 2 for each input signal.');
        end
    end
    
    if opt.varying_cp_times == 1
        
        % Sampling algorithm 1 - corresponding control points have the same time stamp
        if n2>1 && any(diff(cp_array)~=0)
            error(' S-Taliro: The number of control points for multiple signals should be the same when using variable control point times option 1. All the corresponding control points use the same time.');
        else
            InpRange = [InpRange; repmat([0 staliro_SimulationTime],cp_array(1),1)];
        end
        
        if staliro_opt.search_space_constrained.constrained
            error(' S-Taliro: search_space_constrained and varying_cp_times==1 options are not supported at the same time. Use varying_cp_times==2 option.')
        end
        
    elseif opt.varying_cp_times == 2
        
        % Sampling algorithm 2 - each control point has different time stamp
        if staliro_opt.search_space_constrained.constrained
            % Resize arrays to take into account the new search variables
            staliro_opt.search_space_constrained.A_ineq = [staliro_opt.search_space_constrained.A_ineq zeros(size(staliro_opt.search_space_constrained.A_ineq,1),temp_ControlPoints(end)-2*n2)];
        else
            staliro_opt.search_space_constrained.constrained = true; % Make sure the constrained space search option is enabled
            staliro_opt.search_space_constrained.A_ineq = [];
            staliro_opt.search_space_constrained.b_ineq = [];
        end
        n_var_tmp = input_count; 
        for j = 1:n2
            if (staliro_opt.varying_cp_times_coeff*staliro_SimulationTime*cp_array(j)>staliro_SimulationTime)
                error(' staliro : the minimum requested time distance between control points exceeds the total simulation time. Change the staliro_option varying_cp_times_coeff.')
            end
            InpRange = [InpRange; repmat([0 staliro_SimulationTime],cp_array(j)-2,1)]; %#ok<AGROW>
            if cp_array(j)>3
                tot_idx_tmp = cp_array(j)-1; 
                Ac_tmp = zeros(tot_idx_tmp, input_count+temp_ControlPoints(end)-2*n2);
                bc_tmp = ones(tot_idx_tmp, 1)*(-staliro_opt.varying_cp_times_coeff*staliro_SimulationTime); % The interpolation functions require the time points to be different
                Ac_tmp(1,n_var_tmp+1) = 1;
                tot_idx_tmp = tot_idx_tmp-2; 
                for k = 2:tot_idx_tmp
                    Ac_tmp(k-1,n_var_tmp+k) = -1;
                    Ac_tmp(k,n_var_tmp+k) = 1;
                end
                Ac_tmp(tot_idx_tmp,n_var_tmp+tot_idx_tmp+1) = -1;
                Ac_tmp(tot_idx_tmp+1,n_var_tmp+1) = -1;                
                Ac_tmp(tot_idx_tmp+2,n_var_tmp+tot_idx_tmp+1) = 1;                
                bc_tmp(tot_idx_tmp+2) = staliro_SimulationTime*(1-staliro_opt.varying_cp_times_coeff);                
                staliro_opt.search_space_constrained.A_ineq = [staliro_opt.search_space_constrained.A_ineq; Ac_tmp];
                staliro_opt.search_space_constrained.b_ineq = [staliro_opt.search_space_constrained.b_ineq; bc_tmp];
            end
            n_var_tmp = n_var_tmp+cp_array(j)-2;
        end
        
    end
    
end

if staliro_opt.parameterEstimation > 0
    InpRange = [InpRange; vertcat(staliro_Parameter.range)]; 
end

% if the normalization option is set to 1, scale the parameter values to be in [0,1].
% The values will be returned back to the original in compute robustness,
% thereby bypassing the stochastic optimizer. 
if staliro_opt.normalization == 1
    
    if any(find([preds.Normalized]==0))
        error('S-TaLiRo: when the normalization option is used in S-TaLiro, the Normalized option for every predicate should be set to 1.')
    end
    
    staliro_inpRangeUnscaled = InpRange;
    InpRange(end-size(staliro_ParameterIndex,2)+1:end,1) = 0;
    InpRange(end-size(staliro_ParameterIndex,2)+1:end,2) = 1;
end

% Initialize output variables - Avoid growing variables in a loop
results.run(staliro_opt.runs) = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history(staliro_opt.runs) = struct('rob',[],'samples',[],'cost',[]);

%% Run tests
RUNSTATS.resume_collecting();
for ii=1:staliro_opt.runs
    % single_sim_steps = 0;
    if staliro_opt.dispinfo>0
       fprintf('\nRun number %i / %i \n',ii, staliro_opt.runs);
       if staliro_opt.normalization == 1 
           disp('Since the normalized option is set to 1, the values displayed');
           disp('in the optimization process will be normalized as well');
       end
       beep;
    end
    tmc = tic;
    RUNSTATS.new_run();
    if nargout>1
        [getRun, getHistory, sigData] = feval(staliro_opt.optimization_solver,InpRange,staliro_opt);        
        history(ii) = getHistory;
    else
        [getRun, sigData] = feval(staliro_opt.optimization_solver,InpRange,staliro_opt);        
    end
    results.run(ii) = getRun;
    results.run(ii).time = toc(tmc);
    
    % rescale the inputs from the [0,1] range to its original input range
    paramBeginIndex = size(results.run(ii).bestSample,1) - size(staliro_ParameterIndex,2) + 1;
    if staliro_opt.normalization == 1 
        results.run(ii).bestSample(paramBeginIndex:end) = (results.run(ii).bestSample(paramBeginIndex:end)).*(staliro_inpRangeUnscaled(paramBeginIndex:end,2)-staliro_inpRangeUnscaled(paramBeginIndex:end,1))+staliro_inpRangeUnscaled(paramBeginIndex:end,1);
        tempBestSample = results.run(ii).bestSample;
        results.run(ii).paramVal = tempBestSample(paramBeginIndex:end);
    end
    %remove parameter values from the results.run.bestSample array
    results.run(ii).bestSample(paramBeginIndex:end) = [];    
    
    if staliro_opt.dispinfo>0
        disp(['  Running time of run ',num2str(ii),': ',num2str(results.run(ii).time),' sec'])
    end
    if staliro_opt.save_intermediate_results
        intermediateStaliroResults = struct('results', results,'history',history, 'lastFinishedRun',ii); %#ok<NASGU>
        if strcmp(opt.save_intermediate_results_varname,'default') && strcmp(staliro_InputModelType,'simulink')
            save([staliro_InputModel, '_results.mat'], 'intermediateStaliroResults');
        else        
            save([opt.save_intermediate_results_varname, '.mat'], 'intermediateStaliroResults');
        end
    end
end

%% Parameter estimation / mining
if(staliro_opt.parameterEstimation == 0)
    % optRobIndex should contain the index for the run that has either the
    % max or min robustness depending on opt.optimization 
    [~, idx] = feval(opt.optimization,[results.run.bestRob]);
    results.optRobIndex = idx;
elseif(staliro_opt.parameterEstimation > 0)
    foundParam = 0;
    if isequal(staliro_Polarity,-1)
        results.optParamValIndex = 0;
        indexOfBest=1;
        for ii=1:size(results.run,2)
            if(results.run(ii).bestRob<0)
                if (results.run(ii).paramVal<=results.run(indexOfBest).paramVal)
                    indexOfBest=ii;
                    foundParam=1;
                end
            end
        end
        if isequal(foundParam,1)
        results.optParamValIndex = indexOfBest;
		results.polarity = 'negative';
        end
    elseif isequal(staliro_Polarity,1)
        results.optParamValIndex = 0;
        indexOfBest=1;
        for ii=1:size(results.run,2)
            if(results.run(ii).bestRob<0)
                if (results.run(ii).paramVal>=results.run(indexOfBest).paramVal)
                    indexOfBest=ii;
                    foundParam=1;
                end
            end
        end
        if isequal(foundParam,1)
        results.optParamValIndex  = indexOfBest;
		results.polarity = 'positive';
        end
    end
end

%% Return options in case it is modified in staliro
opt = staliro_opt;

end

