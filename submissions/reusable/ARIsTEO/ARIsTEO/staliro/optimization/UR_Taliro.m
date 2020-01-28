% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [run, history, sigData] = UR_Taliro(inpRanges,opt)
% UR_Taliro - Performs random sampling in the state and input spaces.
% Gradient descent can be applied to samples optionally
%
% USAGE:
%   [run, history] = UR_Taliro(inpRanges,opt)
%
% INPUTS:
%
%   inpRanges: n-by-2 lower and upper bounds on initial conditions and
%       input ranges, e.g.,
%           inpRanges(i,1) <= x(i) <= inpRanges(i,2)
%       where n = dimension of the initial conditions vector +
%           the dimension of the input signal vector * # of control points
%
%   opt : staliro options object
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
%               parameter query problems. This is valid if only if
%               bestRob is negative.
%
%           falsified: Indicates whether a falsification occurred. This
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
% See also: staliro, staliro_options, UR_Taliro_parameters

% (C) 2010, Sriram Sankaranarayanan, University of Colorado
% (C) 2010, Georgios Fainekos, Arizona State University
% (C) 2019, Shakiba Yaghoubi, Arizona State University 


tmc = tic;
params = opt.optim_params;
GD_params = opt.optim_params.GD_params;
max_T = opt.optim_params.max_time;
no_dec_TH = GD_params.no_dec_TH;
if params.apply_GD 
    if strcmp('',GD_params.model)
        error('The Simulink model name is not specified, see help GD_parameters')
    else
        assert(~isempty(getlinio(GD_params.model)), 'Linearization I/O are not specified correctly in the Simulink model')
    end
end
nSamples = params.n_tests;
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
    error('The number of tests (opt.ur_params.n_tests) should be divisible by the number of workers.')
end

% Initialize optimization
for jj = 1:opt.n_workers
    curSample{jj} = (inpRanges(:,1)-inpRanges(:,2)).*rand(nInputs,1)+inpRanges(:,2);
end

[curVal, ind, cur_par, rob, sigData] = Compute_Robustness(curSample);

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
no_success = 0;
new_best_sample = 1;

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
    disp(' UR_Taliro: FALSIFIED!');
    return;
end

for i = 2:nSamples/opt.n_workers
    
    for jj = 1:opt.n_workers
        curSample{jj} = (inpRanges(:,1)-inpRanges(:,2)).*rand(nInputs,1)+inpRanges(:,2);
    end
    
    [curVal, ind, cur_par, rob, sigData] = Compute_Robustness(curSample);
    
    if isa(curVal{1},'hydis')
        [minmax_val, minmax_idx] = minmax(hydisc2m(curVal));
    else
        [minmax_val, minmax_idx] = minmax(cell2mat(curVal));
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
    run.nTests = run.nTests+1;

    if (fcn_cmp(minmax_val,bestCost))
        bestCost = minmax_val;
        run.bestCost = minmax_val;
        run.bestRob = minmax_val;
        run.bestSample = curSample{minmax_idx};
        if opt.dispinfo>0
            if isa(minmax_val,'hydis')
                disp(['Best ==> <',num2str(get(minmax_val,1)),',',num2str(get(minmax_val,2)),'>']);
            else
                disp(['Best ==> ' num2str(minmax_val)]);
            end
        end
        if (minmax_val <= 0 && StopCond)
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
            disp('  UR_Taliro: FALSIFIED');
            return;
        end
        no_success = 0;
        new_best_sample = 1;
    else
        no_success = no_success+1;
    end
    if no_success>no_dec_TH && new_best_sample && params.apply_GD
        no_success = 0;
        new_best_sample = 0;
        try
            [minmax_val, Inp,  GD_iter] = feval(GD_params.GD_func, run.bestSample, run.bestRob, tmc, max_T, opt); %%%%%%%%%
        catch
            error('Unable to evaluate the GD function')
        end
        if (fcn_cmp(minmax_val,bestCost))
            bestCost = minmax_val;
            run.bestCost = minmax_val;
            run.bestRob = minmax_val;
            run.bestSample = Inp;
            disp(['best Sample: ',Inp]);
            run.nTests = run.nTests+GD_iter;
            if opt.dispinfo>0
                if isa(minmax_val,'hydis')
                    disp(['Best ==> <',num2str(get(minmax_val,1)),',',num2str(get(minmax_val,2)),'>']);
                else
                    disp(['Best ==> ' num2str(minmax_val)]);
                end
            end
            if (minmax_val <= 0 && StopCond)
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
                disp('  UR_Taliro: FALSIFIED');
                return;
            end
        end
    end
    if opt.dispinfo>0
        if (mod(i,floor(100/opt.n_workers)) == 0)
            disp([' UR_Taliro: Number of tests so far ',num2str(i*opt.n_workers)])
        end
    end
    
    run.falsified = fcn_cmp(minmax_val,0) | run.falsified;
    optime= toc(tmc);
%    disp(['optimization time',num2str(optime)]);
    if toc(tmc)>max_T
        break
    end
end

run.nTests = nSamples;

end
