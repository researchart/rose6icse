% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [run, history, sigData] = SA_Taliro(inpRanges,opt)

% SA_Taliro - Performs stochastic optimization using Simulated Annealing
% with hit and run Monte Carlo sampling where the cost function is the
% robustness of a Metric Temporal Logic formula. For smooth models Gradient
% descent can assist the search optionally (Type "help Apply_Opt_GD_default"
% for more info) . 
%
% USAGE:
% [run, history] = SA_Taliro(inpRanges,opt)
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
% See also: staliro, staliro_options, SA_Taliro_parameters

% (C) 2010, Sriram Sankaranarayanan, University of Colorado
% (C) 2010, Georgios Fainekos, Arizona State University
% (C) 2012, Bardh Hoxha, Arizona State University
% (C) 2019, Shakiba Yaghoubi, Arizona State University

% Last update: 2019.01.21 by SY
global RUNSTATS;
global statistics;
global sim_t;   % simulation time
        global f_eval_t;    % evaluation of the robustness
        
tmc = tic;
params = opt.optim_params;
GD_params = opt.optim_params.GD_params;

if params.apply_GD 
    if strcmp('',GD_params.model)
        error('The Simulink model name is not specified, see help GD_parameters')
    else
        assert(~isempty(getlinio(GD_params.model)), 'Linearization I/O are not specified correctly in the Simulink model')
    end
end

[nInputs, ~] = size(inpRanges);

% Create sample space polyhedron
if opt.search_space_constrained.constrained
    input_lb = inpRanges(:, 1);
    input_ub = inpRanges(:, 2);
    input_A = opt.search_space_constrained.A_ineq;
    input_b = opt.search_space_constrained.b_ineq;
    if isempty(input_A) || isempty(input_b)
        sampleSpace = createPolyhedronFromConstraints(input_lb, input_ub);
    else
        [~, nConsVariables] = size(input_A);
        if nConsVariables < nInputs
            % Constraints are not given for parameters
            input_A(:,end+1:nInputs) = 0;
        end
        sampleSpace = createPolyhedronFromConstraints(input_lb, input_ub, input_A, input_b);
    end
end

nSamples = params.n_tests; % The total number of tests to be executed

%   StopCond : the terminating condition:
%       1 - falsification, i.e., the algorithm stops when a falsifying
%           trajectory is found
%       0 - optimization, i.e., the algorithm stops when the maximum
%           number of tests is performed
StopCond = opt.falsification;

% Initialize outputs
run = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history = struct('rob',[],'samples',[],'cost',[]);

% Adaptation parameters
dispAdap = 1+params.dispAdap/100;
betaXAdap = 1+params.betaXAdap/100;
betaLAdap = 1+params.betaLAdap/100;
nTrials = 1;
nAccepts = 1;

% get polarity and set the fcn_cmp
if isequal(opt.parameterEstimation,1)
    if isequal(opt.optimization,'min')
        if opt.fals_at_zero == 1
            fcn_cmp = @le;
        else
            fcn_cmp = @lt;
        end
    elseif isequal(opt.optimization,'max')
        if opt.fals_at_zero == 1
            fcn_cmp = @ge;
        else
            fcn_cmp = @gt;
        end
    end
    % in case we are doing conformance testing we should switch to a
    % maximization function
    
elseif isequal(opt.optimization,'max')
    if opt.fals_at_zero == 1
        fcn_cmp = @ge;
    else
        fcn_cmp = @gt;
    end
else
    if opt.fals_at_zero == 1
        fcn_cmp = @le;
    else
        fcn_cmp = @lt;
    end
end

%% Initialize optimization

iterationclock=tic;
global curSample;
global socrates_en;
if socrates_en
    if isempty(curSample)
        if opt.search_space_constrained.constrained
            curSample = getNewSampleConstrained(sampleSpace);
        else
            curSample = getNewSample(inpRanges);
        end
        if ~isempty(params.init_sample)
            assert(length(curSample)==length(params.init_sample),' SA_Taliro : The proposed initial sample in params.init_sample does not have correct length');
            curSample = params.init_sample;
        end
        [curVal, ~, tm_param, rob, sigData] = Compute_Robustness(curSample);
         if opt.dispinfo>0
        if ~isequal(opt.parameterEstimation,1)
            disp([' Initial robustness value ==> ' num2str(curVal)]);
        end
         end
    else
         [curVal, ~, tm_param, rob, sigData] = Compute_Robustness(curSample);
    end
else
     if opt.search_space_constrained.constrained
        curSample = getNewSampleConstrained(sampleSpace);
    else
        curSample = getNewSample(inpRanges);
    end
    if ~isempty(params.init_sample)
        assert(length(curSample)==length(params.init_sample),' SA_Taliro : The proposed initial sample in params.init_sample does not have correct length');
        curSample = params.init_sample;
    end
    [curVal, ~, tm_param, rob, sigData] = Compute_Robustness(curSample);
     if opt.dispinfo>0
    if ~isequal(opt.parameterEstimation,1)
        disp([' Initial robustness value ==> ' num2str(curVal)]);
    end
     end
end 


run.bestCost = curVal;
run.paramVal = tm_param;
run.bestSample = curSample;
run.bestRob = rob;
run.falsified = rob<=0;
run.nTests = 1;

if nargout>1
    if isa(curVal,'hydis')
        history.cost = hydis(zeros(nSamples,1));
        history.rob = hydis(zeros(nSamples,1));
    else
        history.cost = zeros(nSamples,1);
        history.rob = zeros(nSamples,1);
    end
    history.cost(1) = curVal;
    history.samples = zeros(nSamples,nInputs);
    history.samples(1,:) = curSample';
    
    % for parameter estimation, update initial sample with parameter end points
    if opt.parameterEstimation == 1
        global staliro_ParameterIndex
        global staliro_Polarity; %#ok<*TLEV>
        
        nrOfParams = size(staliro_ParameterIndex,2);
        if isequal(staliro_Polarity,-1)
            history.samples(1,end-nrOfParams+1:end) = inpRanges(end-nrOfParams+1:end,2)';
            run.bestSample(end-nrOfParams+1:end) = inpRanges(end-nrOfParams+1:end,2);
        else
            history.samples(1,end-nrOfParams+1:end) = inpRanges(end-nrOfParams+1:end,1)';
            run.bestSample(end-nrOfParams+1:end) = inpRanges(end-nrOfParams+1:end,1);
        end         
    end
    
    history.rob(1) = rob;
end



if (fcn_cmp(curVal,0) && StopCond)
    if nargout>1
        if isa(curVal,'hydis')
            history.cost(2:end) = hydis([],[]);
            history.rob(2:end) = hydis([],[]);
        else
            history.cost(2:end) = [];
            history.rob(2:end) = [];
        end
        history.samples(2:end,:) = [];
    end
    disp('FALSIFIED BY INITIAL SAMPLE!');
    return;
end
bestCost = curVal;

if params.apply_local_descent
    global staliro_InputModel;
    global staliro_InputModelType;
    global staliro_SimulationTime;
    if ~strcmp(staliro_InputModelType, 'hautomaton')
        error([' SA_Taliro : Local descent can only apply to systems of type hautomaton. This system is of type ',staliro_InputModelType,'.']);
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

% Local descent, if enabled, will be disabled once max_nbse is exceeded.
% This disabling lasts only for one run, since a new run starts with a new
% budget of nbse.
params.apply_local_descent_this_run = params.apply_local_descent;

iterationtime=toc(iterationclock);
statistics.iterationtime(1)=iterationtime;
statistics.sim_t(1)=sim_t;


%% Start optimization
no_success = 0; GD = 0; no_decrease = 0;
betaX = params.betaXStart;
betaL = params.betaLStart;
displace = params.dispStart;
orig_max_nbse = params.ld_params.max_nbse;


     
RUNSTATS.resume_collecting();
for i = 2:nSamples
    iterationclock=tic;
    if toc(tmc)<opt.optim_params.max_time
    % cur_max_nbse keeps track of how much nbse we still have to spend in
    % this run. RUNSTATS.nb_function_evals_this_run is cumulative.
    cur_max_nbse = orig_max_nbse - RUNSTATS.nb_function_evals_this_run();
    if params.apply_local_descent_this_run && cur_max_nbse <= 0
        disp(['[', mfilename,'] Disabling descent because max_nbse exceeded'])
        params.apply_local_descent_this_run = 0;
        break;
    end
    
    if (mod(i,params.fRestarts)==0)
        disp('RESTART...');
        betaX = params.betaXStart;
        
        s=tic;
        if opt.search_space_constrained.constrained
            curSample1 = getNewSampleConstrained(sampleSpace);
        else
            curSample1 = getNewSample(inpRanges);
        end
        
        history.sample_time(i)=toc(s);

        
        [curVal1, ~, tm_param, rob, sigData] = Compute_Robustness(curSample1);
        
        if nargout>1
            history.cost(i) = curVal1;
            history.samples(i,:) = curSample1';
            history.rob(i) = rob;
           
        end
        if fcn_cmp(curVal1,bestCost)
            bestCost = curVal1;
            run.bestCost = curVal1;
            run.paramVal = tm_param;
            run.bestSample = curSample1;
            run.bestRob = rob;
            
            if (fcn_cmp(curVal1,0) && StopCond)
                disp('FALSIFIED!');
                run.nTests = i;
                run.falsified = 1;
                if nargout>1
                    if isa(curVal,'hydis')
                        history.cost(i+1:end) = hydis([],[]);
                        history.rob(i+1:end) = hydis([],[]);
                    else
                        history.cost(i+1:end) = [];
                        history.rob(i+1:end) = [];
                    end
                    history.samples(i+1:end,:) = [];
                end
                return;
            end
        end
        nAccepts = 1;
        nTrials = 1;
        curSample = curSample1;
        curVal = curVal1;
        
    else
        
        if opt.search_space_constrained.constrained
            curSample1 = getNewSampleConstrained(curSample, sampleSpace, displace);
        else
            curSample1 = getNewSample(curSample,inpRanges,displace);
        end
 
        [curVal1, ~, tm_param,rob, sigData] = Compute_Robustness(curSample1);
        
         
        % restrict parameter search space
        if rob <= 0 && opt.parameterEstimation == 1
            if strcmpi(opt.optimization, 'max')
                inpRanges(end-size(staliro_ParameterIndex,2)+1:end,1) = tm_param;
            else
                inpRanges(end-size(staliro_ParameterIndex,2)+1:end,2) = tm_param;
            end
            if opt.search_space_constrained.constrained
                input_lb = inpRanges(:, 1);
                input_ub = inpRanges(:, 2);
                sampleSpace = createPolyhedronFromConstraints(input_lb, input_ub, input_A, input_b);
            end
        end
        
        if nargout>1
            history.cost(i) = curVal1;
            history.samples(i,:) = curSample1;
            history.rob(i) = rob;
        end
        nTrials = nTrials+1;
        % Two roads to acceptance:
        % I. either by the Metropolis criterion applied to curSample1 and
        % best so far (if-branch), or
        % II. else by usual Metropolis criterion applied to curSample1 and curSample.
        % Descent is applied if the criterion is satisfied.
        % In the 1st case, if accepted, the local min is used as the accepted current sample.
        % In the 2nd case, it's business as usual
        if ( params.apply_local_descent_this_run && mcAccept(curVal1,run.bestCost,betaX,betaL) ==1)
            % I. Apply descent
            fprintf(['\n*** Descending from candidate nb ',num2str(i),' / ',num2str(nSamples),' with robustness ', num2str(curVal1),' with a budget of ', num2str(params.ld_params.red_nb_ellipsoids),' ellipsoids ***\n']);
            nAccepts = nAccepts+1;
            RUNSTATS.add_descent_acceptances(1);
            %---------------------------------------------------------------------------
            r_orig = curVal1;
            descentargv.max_nbse       = cur_max_nbse;
            descentargv.base_sample_rob = r_orig;
            argv = struct('descentargv', descentargv, ...
                'plotit', opt.plot, ...
                'hinitial', [], ...
                'local_minimization_algo', params.ld_params.local_minimization_algo, 'red_nb_ellipsoids', params.ld_params.red_nb_ellipsoids);
            desc_outargv                    = apply_descent_to_sample(curSample1, argv, opt);
            r_sol                           = desc_outargv.r_sol;
            %---------------------------------------------------------------------------
            % Use local min as current sample
            if r_sol < r_orig
                curSample1  = desc_outargv.h_sol(3:end)';
                curVal1     = r_sol;
                rob         = r_sol;
            end
            % Local minima from descent are always accepted.
            curSample = curSample1;
            curVal = curVal1;
        elseif ( params.apply_GD && (no_success>=GD_params.no_suc_TH || no_decrease>=GD_params.no_dec_TH) && mcAccept(curVal1,run.bestCost,betaX,betaL) ==1)
            GD = 1;
            [r_sol, u_saved, n_sim] = feval(GD_params.GD_func,run.bestSample, run.bestCost, tmc, params.max_time, opt);
            run.nTests = i+n_sim;
            curSample1  = u_saved;
            curVal1     = r_sol;
            rob         = r_sol;
            curSample = curSample1;
            curVal = curVal1;                      
        else
            % II. Usual Metropolis-Hastings criterion
            if ( mcAccept(curVal1,curVal,betaX,betaL)==1)
                nAccepts = nAccepts+1;
                curSample = curSample1;
                curVal = curVal1;
                no_success = 0;            
            else
                no_success = no_success+1;
            end
            
        end
        
        % Determine if the candidate is a new best...
        if fcn_cmp(curVal1,bestCost)
            bestCost = curVal1;
            run.bestCost=curVal1;
            run.paramVal=tm_param;
            run.bestSample=curSample1;
            run.bestRob=rob;
            
            if isequal(opt.parameterEstimation,1)
                best = tm_param;
            else
                best = curVal1;
            end
            if opt.dispinfo>0
                disp(['Best ==> ' num2str(best')]);
            end
            % ... then if we falsified...
            if (fcn_cmp(curVal1,0) && StopCond)
                run.nTests = i;
                run.falsified = 1;
                disp(['FALSIFIED at sample ,',num2str(i),'!']);
                if nargout>1
                    if isa(curVal,'hydis')
                        history.cost(i+1:end) = hydis([],[]);
                        history.rob(i+1:end) = hydis([],[]);
                    else
                        history.cost(i+1:end) = [];
                        history.rob(i+1:end) = [];
                    end
                    history.samples(i+1:end,:) = [];
                end
                return;
            end
            no_decrease = 0;            
        else
            no_decrease = no_decrease+1;            
        end
        if GD
            break
        end
        
        
        % Update acceptance criteria
        if (mod(nTrials,50) == 0)
            acRatio=nAccepts/nTrials;
            if (acRatio > params.acRatioMax)
                %% reduce beta - Increase displacement
                displace = displace*dispAdap;
                betaX = betaX*betaXAdap;
                betaL = betaL*betaLAdap;
                nTrials = 0;
                nAccepts = 0;
            elseif (acRatio < params.acRatioMin)
                displace = displace/dispAdap;
                betaX = betaX/betaXAdap;
                betaL = betaL/betaLAdap;
                nTrials = 0;
                nAccepts = 0;
            end
            if (displace >= params.maxDisp)
                displace = params.maxDisp;
            end
            if (displace <= params.minDisp)
                displace = params.minDisp;
            end
            if opt.dispinfo>0
                disp([num2str(i),  ' Acceptance Ratio=' num2str(acRatio) ' beta=' num2str(betaX) ',' num2str(displace) ])
            end
        end
        
    end
     iterationtime=toc(iterationclock);
     statistics.iterationtime(i)=iterationtime;
     statistics.sim_t(i)=sim_t;

     sim_t=-1000;

     f_eval_t=-1000;
         
    run.falsified = fcn_cmp(curVal,0) | run.falsified;
    else
        break
    end
end
curSample=run.bestSample;

RUNSTATS.stop_collecting();
run.nTests = nSamples;

%% Auxiliary functions
    function rBool = mcAccept(newVal,curVal,betaX,betaL)
        if fcn_cmp(newVal,curVal)
            rBool = 1;
        else
            % For hybrid traces
            if isa(newVal,'hydis')
                if ((get(newVal,1)==get(curVal,1)) && (get(newVal,2)<inf))
                    rat = get(newVal,2)-get(curVal,2); %% rat >= 0 %% beta < 0
                    rBool=0;
                    if (exp(betaX*rat) >= rand(1))
                        rBool=1;
                    end
                else
                    rat = get(newVal,1)-get(curVal,1); %% rat >= 0 %% beta < 0
                    rBool=0;
                    if (exp(betaL*rat) >= rand(1))
                        rBool=1;
                    end
                end
                % For non-hybrid traces
            else
                rat = (newVal-curVal); %% rat >= 0 %% beta < 0
                rBool=0;
                if (exp(betaX*rat) >= rand(1))
                    rBool=1;
                end
            end
        end
    end

end
