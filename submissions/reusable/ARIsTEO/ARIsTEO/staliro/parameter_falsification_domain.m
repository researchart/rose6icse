% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [results] ...
    = parameter_falsification_domain(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, opt)

% parameter_falsification_domain
%
% USAGE:
% [results] =
%       parameter_falsification_domain(model,init_cond,input_range,cp_array,phi,preds,TotSimTime,opt)
%
% DESCRIPTION :
%       the parameter_falsification_domain function enables the exploration
%       of the parameter space for monotonic specifications with multiple
%       parameters.
%
% INPUTS :
%   - model : can be of type function handle or string:
%       * function handle represents a pointer to a function, 
% 		* string represents a Simulink model.
%
%       Examples: 
%           model = @function_name;
%           model = 'sim_model';
%		
%		Important: When choosing a function handle as a model, then you 
%		must set in staliro_options whether this should be treated as a
%		black box or an a function to be numerically integrated. The
%		required interface for black box functions is explained in 
%		staliro_options. The default numerical integrator for functions 
%		to be integrated is ode45.
%
%		For black box setup see the demos:
%			staliro_demo_sa_simpleODE_param.m
%			staliro_demo_autotrans_02.m
%			staliro_demo_autotrans_03.m
%
%   - init_cond : a hyper-rectangle that holds the range of the initial 
%       conditions and it should be a Matlab n x 2 array, where n is the 
%       size of the vector of initial conditions. The array can 
%       be empty(indicating no search over initial conditions) or of 
%       dimension m by 2, where m is an integer.
%
%       Format: [LowerBound UpperBound];
%
%       Examples: 
%           init_cond = [3 6;7 8;9 12]; 
%           init_cond = [];
%
%   - input_range : a hyper-rectangle that holds the range of the input 
%       signals. This is a Matlab m x 2 array, where m is the number of 
%       inputs to the model. The array can be empty (indicating no input
%       conditions).
%
%       Format [LowerBound UpperBound];
%
%       Examples: 
%           input_range = [5.6 7.8;8 12]; 
%           input_range = [];
%
%   - phi : Formula to falsify, should be a string. For the syntax of MTL 
%       formulas type "help dp_taliro" or "help fw_taliro" depending on the
%       temporal logic robustness toolbox that you will be using.
%                               
%       Example: 
%           phi = '!<>_[3.5,4.0] b)'
%
%       Note: phi can be empty in case the model is a hybrid automaton 
%       object. In this case, an unsafe set must be provided in the hybrid
%       automaton.
%
%   - preds : contains the mapping of the predicates in the formula. For 
%       help defining predicate mappings type "help dp_taliro" or 
%       "help fw_taliro" depending on the temporal logic robustness 
%       toolbox that you will be using.
%
%   - TotSimTime : maximum simulation time.
%
%   - cp_array : contains the control points associated with each input.
%       It should be a vector (1 x n array) and its length must be equal 
%       to the number of inputs for the system.
%
%       Example: 
%           cp_array = [10 14];
%               indicates 10 control points for the 1st input signal and 
%               14 for the second input.
%
%   - opt : opt should be of type staliro_options. 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change S-Taliro options, 
%       type "help staliro_options"
%
% OUTPUTS
%   - results: a structure with the following fields
%
%       - polyhedron: stores a polyhedron (requires MPT toolbox to be
%       installed) of the falsification domain in the parameter space.
%
%       - listOfKnees: cell array of knees discovered by the parameter
%       falsification domain algorithms.
%
%		- polarity: indicates whether the specification has positive or 
%			negative polarity
%
%       - time: time taken to run the algorithm. 
%
% See also : staliro_options, SimSimulinkMdl, SimFunctionMdl, 
% 			 fw_taliro, dp_taliro, dp_t_taliro, polarity
%
% (C) 2015, Bardh Hoxha, Arizona State University
%
% Please send reports for bugs and/or comments for improvements to 
%               fainekos @ gmail.com
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

% If the seed for the random number generator is prespecified set it
if opt.seed ~= 0
    if verLessThan('matlab', '7.12')
        stream = RandStream('mt19937ar','Seed',opt.seed);
        RandStream.setDefaultStream(stream);
    else
        rng(opt.seed);
    end
        

end

if ~((opt.taliro_undersampling_factor >=1) && (mod(opt.taliro_undersampling_factor,1)==0)); 
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

% Check to see if initial ranges and input conditions have been declared correctly
if isempty(init_cond) 
%     if ~strcmp(staliro_InputModelType,'simulink')
%         error('S-Taliro: Initial conditions might be omitted only when the model is a Simuliink model')
%     end
    if isempty(input_range)
        error('S-Taliro: The initial conditions and the input ranges cannot be empty at the same time')
    end
end
if ~isempty(input_range) && size(input_range,2)~=2
    error('S-Taliro: Input ranges are not in the right format. Please look the help file.')
end
if (~isreal(init_cond) || ~isreal(input_range))
    error('S-Taliro: initial conditions or input ranges are not of type real');
end
[staliro_dimX,n1] = size(init_cond);
if (n1>2)
    error('S-Taliro: Initial conditions are not in the right format. Please look the help file.')
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
  
% Verify that the inputs are in the right format
if xor(isempty(input_range),isempty(cp_array))
    error('S-Taliro: if "input_range" is empty, then "cp_array" must be empty and vice versa')
end
if ~isempty(cp_array)
    if (isreal(cp_array)) && isvector(cp_array)
        if size(input_range,1)~=length(cp_array)
            error('S-Taliro: The sizes of the input bounds and the control points do not match.')
        end
        for i=1:length(cp_array)
            if (cp_array(i) < 1)
                error(['S-Taliro: The control points associated with every input must be greater than 1. See input signal ',num2str(i),'.']);
            end
            if length(staliro_opt.interpolationtype)>1
                idx = i;
            else
                idx = 1;
            end
            if ~strcmp(staliro_opt.interpolationtype{idx},'const') && (cp_array(i)==1)
                error(['S-Taliro: The interpolation function "',staliro_opt.interpolationtype{idx},'" for input signal ',num2str(i),' requires more than 1 control points.'])
            end
            if strcmp(staliro_opt.interpolationtype{idx},'const') && (cp_array(i)~=1)
                error(['S-Taliro: Input signal ',num2str(i),' is set to be constant, but it is set to more than 1 control points. Change the corresponding control points to 1.'])
            end
        end
    else
        error('S-Taliro: cp_array must be a vector of type real');
    end
end

% Check the input interpolation functions
if ((length(staliro_opt.interpolationtype)>1) && (length(cp_array)~=length(staliro_opt.interpolationtype))) 
    error('S-Taliro: The number of inputs are not equal to the number of interpolation types. Common error: Make sure you are using a cell array for the interpollation type.');
end

[m,dum] = size(input_range); %#ok<NASGU>
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
[m1,dum] = size(input_range); %#ok<NASGU>
n2 = length(cp_array);
if(m1~=n2)
    error('S-Taliro: Row size of input ranges must be equal to the column size of cp_array.');
end

% compute the total number of control points
input_count = size(init_cond,1);
for i=1:length(cp_array)
    input_count = input_count + cp_array(i);
end

% Initialize output variables - Avoid growing variables in a loop
results = struct('polyhedron',[],'listOfKnees',[], 'polarity',[],  'time',[]);

InpRange = init_cond;

for j = 1:n2
    InpRange = [InpRange; repmat(input_range(j,:),cp_array(j),1)]; %#ok<AGROW>
end

if opt.varying_cp_times == 1
    if temp_ControlPoints(end) < 2
        error('S-Taliro: the number of control points when using the variable control times option should be greater than 1');
    end    
    if n2>1 && any(diff(cp_array)~=0)
        error('S-Taliro: The number of control points for multiple signals should match when using variable control point times');
    else
        InpRange = [InpRange; repmat([0 staliro_SimulationTime],cp_array(1),1)];
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

%% Run tests
if staliro_opt.dispinfo>0
    if staliro_opt.normalization == 1
        disp('Since the normalized option is set to 1, the values displayed');
        disp('in the optimization process will be normalized as well');
    end
    beep;
end
tmc = tic;

getRun = feval(staliro_opt.optimization_solver,InpRange,staliro_opt);

results = getRun;
results.time = toc(tmc);

param_range = vertcat(staliro_Parameter.range);

if opt.optim_params.plot == 1 
    if size(param_range,1) == 1
        title('Parameter Falsification Domain')
        results.polyhedron.plot('LineStyle','-','LineWidth',2);
        title('Parameter Falsification Domain')
    elseif size(param_range,1) == 2 
        results.polyhedron.plot('LineStyle','none','color','r');
        axis(reshape(param_range.',1,length(param_range(:))))
        title('Parameter Falsification Domain')
        xlabel(staliro_Parameter(1).par)
        ylabel(staliro_Parameter(2).par)
    elseif length(param_range) == 3
        results.polyhedron.plot('LineStyle','none','color','r');
        axis(reshape(param_range.',1,length(param_range(:))))
        title('Parameter Falsification Domain')
        xlabel(staliro_Parameter(1).par)
        ylabel(staliro_Parameter(2).par)
        zlabel(staliro_Parameter(3).par)
    else
        disp('')
        disp('Can only plot two and three dimensional parameter spaces')
        disp('')
    end
end

    if isequal(staliro_Polarity,-1)
        results.polarity = 'negative';
    elseif isequal(staliro_Polarity,1)
		results.polarity = 'positive';
    end
end

