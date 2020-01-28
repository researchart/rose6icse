% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [run, history, sigData] = MS_Taliro(inpRanges,opt)
% MS_Taliro - Performs Multi-Start with local gradient descent starting 
% from each point. Currenlty, MS_Taliro works only with hybrid automata of
% type hautomaton (see help hautomaton).
%
% USAGE:
%   [run, history] = MS_Taliro(inpRanges,opt)
%
% INPUTS:
%
%   inpRanges: n-by-2 lower and upper bounds on initial conditions and
%       input ranges, e.g.,
%           inpRanges(i,1) <= x(i) <= inpRanges(i,2)
%       where n = dimension of the initial conditions vector +
%           the dimension of the input signal vector * # of control points
%
%   opt : staliro_options object
%
% OUTPUTS:
%   run: a structure array that contains the results of each run of
%       the stochastic optimization algorithm. The structure has the
%       following fields:
%
%           bestRob : The best (min or max) robustness value found
%
%           bestSample : The sample in the search space that generated
%               the trace with the best robustness value.
%
%           nTests: number of tests performed (this is needed if
%               falsification rather than optimization is performed)
%
%           bestCost: Best cost value. bestCost and bestRob are the
%               same for falsification problems. bestCost and bestRob
%               are different for parameter estimation problems. The
%               best robustness found is always stored in bestRob.
%
%           paramVal: Best parameter value. This is used only in
%               parameter querry problems. This is valid if only if
%               bestRob is negative.
%
%           falsified: Indicates whether a falsification occured. This
%               is used if a stochastic optimization algorithm does not
%               return the minimum robustness value found.
%
%           time: The total running time of each run. This value is set by
%               the calling function.
%
%   history: array of structures containing the following fields
%
%       rob: all the robustness values computed for each test
%
%       samples: all the samples generated for each test
%
%       cost: all the cost function values computed for each test.
%           This is the same with robustness values only in the case
%           of falsification.
%
% See also: staliro, staliro_options

% (C) 2010, Sriram Sankaranarayanan, University of Colorado
% (C) 2010, Georgios Fainekos, Arizona State University


global RUNSTATS;
global staliro_InputModel;
global staliro_InputModelType;
global staliro_SimulationTime;

params = opt.optim_params;

nSamples = params.n_tests; % nb initial points in multi-start
StopCond = opt.falsification;

[nInputs, ~] = size(inpRanges); 

% Initialize outputs
run = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history = struct('rob',[],'samples',[],'cost',[]);

%initialize curSample vector
curSample = repmat({0}, 1, opt.n_workers);

% get polarity and set the fcn_cmp
if isequal(opt.parameterEstimation,1)
    if isequal(opt.optimization,'min')
        fcn_cmp = @le;
        minmax = @min;
    elseif isequal(opt.optimization,'max')
        fcn_cmp = @ge;
        minmax = @max;
    end
else
    fcn_cmp = @le;
    minmax = @min;
end

if rem(nSamples/opt.n_workers,1) ~= 0
    error(' MS_Taliro : The number of tests (n_tests) should be divisible by the number of workers (n_workers).')
end

% Initialize optimization
for jj = 1:opt.n_workers
    curSample{jj} = (inpRanges(:,1)-inpRanges(:,2)).*rand(nInputs,1)+inpRanges(:,2);
end

%[curVal, sigData] = Compute_Robustness(curSample);
[curVal, ~, tm_param, rob, sigData]= Compute_Robustness(curSample);
if nargout>1
    if isa(curVal{1},'hydis')
        history.cost = hydis(zeros(nSamples,1));
        history.rob = hydis(zeros(nSamples,1));
        history.cost(1:opt.n_workers) = hydisc2m(curVal)';
        history.rob(1:opt.n_workers) = hydisc2m(curVal)';
    else
        history.cost = zeros(nSamples,1);
        history.rob = zeros(nSamples,1);
        history.cost(1:opt.n_workers) = cell2mat(curVal)';
        history.rob(1:opt.n_workers) = cell2mat(curVal)';
    end
    
    history.samples = zeros(nSamples,nInputs);
    history.samples(1:opt.n_workers,:) = cell2mat(curSample)';
    
end

if isa(curVal{1},'hydis')
    [minmax_val, minmax_idx] = minmax(hydisc2m(curVal));
else
    [minmax_val, minmax_idx] = minmax(cell2mat(curVal));
end
bestCost = minmax_val;

run.bestCost = minmax_val;
run.bestSample = curSample{minmax_idx};
run.bestRob = minmax_val;
run.falsified = minmax_val<=0;
run.nTests = 1;

if (fcn_cmp(minmax_val,0) && StopCond)
    if nargout>1
        if isa(minmax_val,'hydis')
            history.cost(2:end) = hydis([],[]);
            history.rob(2:end) = hydis([],[]);
        else
            history.cost(2:end) = [];
            history.rob(2:end) = [];
        end
        history.samples(2:end,:) = [];
    end
    disp('FALSIFIED!');
    return;
end


% Generate initial points using a Halton sequence
step = 1;
seed = 1*ones(nInputs,1);
leap = ones(nInputs,1);
base = primes(nInputs*nInputs+1);
base = base(1:nInputs);

r = halton_sequence(nInputs,nSamples, step, seed, leap, base);
r = kron(r, ones(1,1));

if(params.strictly_inside)
    epsi = 0.01*(inpRanges(:,2)-inpRanges(:,1));
else
    epsi = 0;
end
pts = repmat(inpRanges(:,1),1, nSamples) + r.*repmat((inpRanges(:,2)-inpRanges(:,1) - epsi),1,nSamples);   

if opt.plot
    for i=1:nSamples
        plot(pts(1,i),pts(2,i), 'rx')        
    end    
end

% Prepare descent parameters
if params.apply_local_descent
    
    if ~strcmp(staliro_InputModelType, 'hautomaton')
        error(['Local descent can only apply to systems of type hautomaton. This system is of type ',staliro_InputModelType,'.']);
    end
    
    descentargv = struct('HA', staliro_InputModel, ...
        'tt', staliro_SimulationTime, ...
        'constr_type', 'invariants', ...
        'testing_type', 'trajectory', ...
        'formulation', 'instant', ...
        'use_slack_in_ge', 0, ...
        'complete_history', 0, ...
        'plotit', opt.plot,  ...
        'red_descent_in_ellipsoid_algo', params.ld_params.red_descent_in_ellipsoid_algo,...
        'red_hard_limit_on_ellipsoid_nbse', params.ld_params.red_hard_limit_on_ellipsoid_nbse, ...
        'max_nbse', params.ld_params.max_nbse,...
        'red_min_ellipsoid_radius', params.ld_params.red_min_ellipsoid_radius);        
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trying to preserve this parallelism thing...
k=0;
% We always want to get the robustness at each of the initial points, 
% regardless of descent. So to avoid descent iterations using up our budget 
% of nbse, we subtract that from orig_max_nbse and reserve it. If cur_max_nbse drops
% to 0, we know we can at least get the robustness values at the remaining
% init points.
orig_max_nbse = params.ld_params.max_nbse - nSamples;
% Decide at which init points to potentially do descent
nbse_per_initpnt = ceil(orig_max_nbse/nSamples);
if nbse_per_initpnt >=1 
    ix_descend = 1:nSamples;
else
    ix_descend = 1:ceil(1/nbse_per_initpnt):nSamples;
end
% Local descent, if enabled, will be disabled once max_nbse is exceeded.
% This disabling lasts only for one run, since a new run starts with a new
% budget of nbse.
params.apply_local_descent_this_run = params.apply_local_descent;

for i = 2:nSamples/opt.n_workers
%    nbSamplesUsed = i*opt.n_workers;
    % cur_max_nbse keeps track of how much nbse we still have to spend in
    % this run. RUNSTATS.nb_function_evals_this_run is cumulative. 
	cur_max_nbse = orig_max_nbse - RUNSTATS.nb_function_evals_this_run();
    if (params.apply_local_descent_this_run && cur_max_nbse <= 0 )
        disp(['[', mfilename,'] Disabling descent because max_nbse is exceeded. Evaluation at the initial multi-start points continues.'])
        params.apply_local_descent_this_run = 0;        
    end
          
    for jj = 1:opt.n_workers
        curSample{jj} = pts(:,k+jj);
    end
    k = k+opt.n_workers;
    
    curVal = Compute_Robustness(curSample);
    
    if isa(curVal{1},'hydis')
        [minmax_val, minmax_idx] = minmax(hydisc2m(curVal));
    else
        [minmax_val, minmax_idx] = minmax(cell2mat(curVal));
    end
    
%     disp(num2str([cur_max_nbse, i, ceil(nSamples - nbSamplesUsed)]))
    if ( params.apply_local_descent_this_run && acceptDescent(minmax_val, bestCost, ix_descend, i, cur_max_nbse, nSamples) )
        % I. Apply descent
        fprintf(['\n*** Descending from candidate nb ',num2str(i+minmax_idx),' / ',num2str(nSamples),' with robustness ', num2str(minmax_val),' with a budget of ', num2str(params.ld_params.red_nb_ellipsoids),' ellipsoids ***\n']);
        RUNSTATS.add_descent_acceptances(1);
        % temp = RUNSTATS.nb_function_evals_this_run();
        %---------------------------------------------------------------------------
        r_orig                         = minmax_val;
        descentargv.max_nbse           = cur_max_nbse;
        descentargv.nbse_per_descent   = ceil(cur_max_nbse / (params.n_tests- (i-1)));
        descentargv.base_sample_rob    = r_orig;
        argv = struct('descentargv', descentargv, ...
            'plotit', opt.dispinfo, ...
            'hinitial', [], ...
            'local_minimization_algo', params.ld_params.local_minimization_algo, ...
            'red_nb_ellipsoids', params.ld_params.red_nb_ellipsoids);
        disp(['     Nbse for this descent = ',num2str(descentargv.nbse_per_descent),'.'])
        desc_outargv                   = apply_descent_to_sample(curSample{minmax_idx}, argv, opt);
        %---------------------------------------------------------------------------     
        % Use local min as current sample
        % Note we are completely over-writing the sample from which we
        % descended. This might affect the average robustness, but we don't
        % care for average robustness since this is a deterministic algo,
        % we only care about the min..
        r_sol = desc_outargv.r_sol;
        
        if r_sol < r_orig
            curSample{minmax_idx}   = desc_outargv.h_sol(3:end)';
            curVal{minmax_idx}      = r_sol;
            minmax_val              = r_sol;
        end        
    end         
              
    if nargout>1
        if isa(curVal{1},'hydis')
            history.cost((i-1)*opt.n_workers+1 : i*opt.n_workers) = hydisc2m(curVal)';
            history.rob((i-1)*opt.n_workers+1 : i*opt.n_workers) = hydisc2m(curVal)';
        else
            history.cost((i-1)*opt.n_workers+1 : i*opt.n_workers) = cell2mat(curVal)';
            history.rob((i-1)*opt.n_workers+1 : i*opt.n_workers) = cell2mat(curVal)';
        end
        history.samples((i-1)*opt.n_workers+1 : i*opt.n_workers , :) = cell2mat(curSample)';
    end
    
    if (fcn_cmp(minmax_val,bestCost))
        bestCost = minmax_val;
        run.bestCost = minmax_val;
        run.bestRob = minmax_val;
        run.bestSample = curSample{minmax_idx};
        if opt.dispinfo>0
            disp(['Best ==> ' num2str(minmax_val)]);
        end
        if (minmax_val <= 0 && StopCond)
            run.nTests = i;
            run.falsified = 1;
            if nargout>1
                if isa(minmax_val,'hydis')
                    history.cost(i*opt.n_workers+1:end) = hydis([],[]);
                    history.rob(i*opt.n_workers+1:end) = hydis([],[]);
                else
                    history.cost(i*opt.n_workers+1:end) = [];
                    history.rob(i*opt.n_workers+1:end) = [];
                end
                history.samples(i*opt.n_workers+1:end,:) = [];
            end
            disp('FALSIFIED');
            return;
        end
    end
    
    if opt.dispinfo>0
        if (mod(i,100) == 0)
            disp([' Number of tests so far ',num2str(i)])
        end
    end
    
    run.falsified = fcn_cmp(minmax_val,0) | run.falsified;
    
end

run.nTests = nSamples;
%===================================================================
% Embedded functions

    function rBool = acceptDescent(~, ~, ix_descend, i, ~, ~) 
        rBool = ~isempty(find(ix_descend == i, 1));
    end

%     function rBool = acceptDescent(newVal, bestVal, ix_descend, i, ~, ~)
%         rBool = (newVal <= 1.1*bestVal) && (find(ix_descend == i));
%     end

%===================================================================

end
