% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% CE_Taliro - Performs stochastic optimization based on a Cross Entropy
%   algorithm where the cost function is the robustness of the metric
%   temporal logic formula.
%
% USAGE:
% [run, history] = CE_Taliro(inpRanges,opt)
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
% (C) 2012, Bardh Hoxha, Arizona State University

function [run, history] = CE_Taliro(inpRanges, opt)

assert(opt.varying_cp_times==0, ' CE_Taliro does not currently support variable times for the control points.');

ce_params = opt.optim_params;

% INPUTS:
[nInputs, dummyVar] =size(inpRanges);
assert(dummyVar == 2, 'The input range matrix must have exactly two columns');
for i = 1:nInputs
    assert( inpRanges(i,1) <= inpRanges(i,2), 'Illegal ranges for initial conditions');
end

% Initialize outputs
run = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history = struct('rob',[],'samples',[],'cost',[]);

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

% Set up variables
falsified = 0;
run.falsified = falsified;
N = ce_params.num_subdivs;
subDivs(1:nInputs,1) = N;

%initialize curSample vector
curSample = repmat({0}, 1, opt.n_workers);

% The n_tests will have to be integrated here
testsPerRound = ce_params.n_tests/ce_params.num_iteration;
nSamplesPerRound = testsPerRound/opt.n_workers;
nRounds = ce_params.num_iteration;
verbose = opt.dispinfo;

if rem(testsPerRound,1) ~= 0 
    error(' CE_Taliro : The number of tests (n_tests) should be divisible by the number of iterations per round (num_iteration).')
elseif rem(nSamplesPerRound,1) ~= 0 
    error(' CE_Taliro : The number of tests (n_tests) divided by the number of iterations per round (num_iteration) should be divisible by the number of workers (n_workers).')
end

%% Generate the initial uniform distribution for each system and control input
% initialize the matrices for the distribution with the uniform distribution.
nSamplesTilt = ceil(nSamplesPerRound*opt.n_workers/ce_params.tilt_divisor);
distrib(1:nInputs,1:N) = 1/N;

bestFound = 0;

if (nargout > 1)
    if (isequal(opt.taliro_metric,'hybrid_inf') || isequal(opt.taliro_metric,'hybrid')) && opt.map2line == 0
        history.rob = hydis(zeros(nRounds*nSamplesPerRound*opt.n_workers, 1));
        bestSampleValue = hydis(zeros(1));
    else
        history.rob = zeros(nRounds*nSamplesPerRound*opt.n_workers, 1);
        bestSampleValue = zeros(1);
    end
    history.samples = zeros(nRounds*nSamplesPerRound*opt.n_workers, nInputs);
end

%% Now let us start by conducting a round.
%% 1. Make samples
%% 2. Evaluate samples
%% 3. Sort and choose top 10% of the samples
%% 4. Tilt the distribution
nCycles = 0;
run.nTests = nCycles;
%%hRounds = waitbar(0,'Rounds of CE method');
%%hSim=waitbar(0,'Running Simulations.. ');
for round = 1: nRounds
    %%waitbar(round/nRounds, hRounds);
    %%disp('Round=')
    %%disp(round)
    
    if (verbose >= 1)
        disp([' CE_Taliro : Round # ',num2str(round)]);
        if verbose>=2
            figure(round)
            fTitle=sprintf('Distribution at round # %d',round);
            title(fTitle);
            for ll=1:nInputs
                subplot(nInputs,1,ll)
                bar(distrib(ll,:))
            end
        end
    end
    
    samples = zeros(nInputs,nSamplesPerRound);
    
    for i = 1:nSamplesPerRound
        %%        waitbar(i/nSamplesPerRound,hSim)
        nCycles = nCycles +1;
        run.nTests = nCycles*opt.n_workers;
        
        for jj = 1:opt.n_workers
            curSample{jj} = chooseBernoulliSamples(inpRanges, subDivs,distrib);
        end
        
        curVal = Compute_Robustness(curSample);
        
        if (isa(curVal{1}, 'hydis'))
            sortedCurVal = quickSortHydisCell(curVal);
            bestRob = sortedCurVal{1,1};
            bestIdx = sortedCurVal{2,1};
            hybridDistanceMetric = 1;
        else
            [bestRob, bestIdx] = min(cell2mat(curVal));
            hybridDistanceMetric = 0;
        end
        violation = violationFound(bestRob,hybridDistanceMetric);
        if (violation == 1)
            if (nargout > 1)
                if hybridDistanceMetric == 1
                    history.rob((round-1) * nSamplesPerRound + (i-1) * opt.n_workers + 1  :  (round-1) * nSamplesPerRound + i * opt.n_workers) = hydisc2m(curVal);
                    history.rob(nCycles+1:end) = hydis([],[]);
                else
                    history.rob((round-1) * nSamplesPerRound + (i-1) * opt.n_workers + 1  :  (round-1) * nSamplesPerRound + i * opt.n_workers) = cell2mat(curVal);
                    history.rob(nCycles+1:end) = [];
                end
                history.samples((round-1) * nSamplesPerRound + (i-1) * opt.n_workers + 1  :  (round-1) * nSamplesPerRound + i * opt.n_workers, 1 : nInputs) = cell2mat(curSample)';
                history.samples(nCycles+1:end,:)=[];
            end
            bestSample = curSample{bestIdx};
            
            if verbose>=1
                if isa(bestRob,'hydis')
                    disp(['  Best ==> <',num2str(get(bestRob,1)),',',num2str(get(bestRob,2)),'>']);
                else
                    disp(['  Best ==> ' num2str(bestRob)]);
                end
                disp ('CE_Taliro : Found falsifying input. RETURN.');
            end
            
            falsified=1;
            run.falsified = falsified;
            run.bestRob = bestRob;
            run.bestSample = bestSample;
            return;
        end
        samples(:,(i-1)*opt.n_workers + 1:i*opt.n_workers) = cell2mat(curSample);
        if hybridDistanceMetric == 1
            history.rob((round-1) * nSamplesPerRound * opt.n_workers + (i-1) * opt.n_workers + 1  :  (round-1) * nSamplesPerRound * opt.n_workers + i * opt.n_workers) = hydisc2m(curVal);
        else
            history.rob((round-1) * nSamplesPerRound * opt.n_workers + (i-1) * opt.n_workers + 1  :  (round-1) * nSamplesPerRound * opt.n_workers + i * opt.n_workers) = cell2mat(curVal);
        end
        history.samples((round-1) * nSamplesPerRound + (i-1) * opt.n_workers + 1  :  (round-1) * nSamplesPerRound + i * opt.n_workers, 1 : nInputs) = cell2mat(curSample)';
    end
    
    %% Sort the samples in the ascending order
    if hybridDistanceMetric == 1
        sortedSampleRobustness = quickSortHydisCell(mat2cell(history.rob( (round - 1) * nSamplesPerRound * opt.n_workers + 1 : round * nSamplesPerRound * opt.n_workers )' , 1 , ones(1, round * nSamplesPerRound * opt.n_workers - ((round - 1) * nSamplesPerRound * opt.n_workers)))); %#ok<MMTC>
        I = cell2mat(sortedSampleRobustness(2,:))';
        topVal = sortedSampleRobustness{1,1};
    else
        historySamples = history.rob((round - 1) * nSamplesPerRound * opt.n_workers + 1: round * nSamplesPerRound * opt.n_workers);
        [sortedSampleRobustness, I] = sortrows(historySamples);
        topVal = sortedSampleRobustness(1,1);
    end
    
    sortedSamples = samples(:, I(1:min([nSamplesTilt, length(I)])));
 
    if ((bestFound == 0) || (topVal < bestSampleValue)  )
        bestSample = sortedSamples(:,1);
        bestSampleValue = topVal;
        bestFound = 1;
        rob = topVal;
        run.falsified = falsified;
        run.bestRob = rob;
        run.bestSample = bestSample;
        
        if isa(topVal,'hydis')
            disp(['  Best ==> <',num2str(get(topVal,1)),',',num2str(get(topVal,2)),'>']);
        else
            disp(['  Best ==> ' num2str(topVal)]);
        end
        
    end
    
    %% We will now tilt
    for i = 1:nInputs
        n = subDivs(i,1);
        distrib(i,:) = tiltBernoulliDistribution(distrib(i,:), sortedSamples(i,:), inpRanges(i,1), inpRanges(i,2), n );
    end
    
    if verbose>=1
        disp([' CE_Taliro : ',num2str(round*nSamplesPerRound*opt.n_workers),' tests have been performed.'])
    end
    
end
    function vFound = violationFound(curSampleRobustness, hybridMetric)
        vFound = 0;
        if (hybridMetric == 0)
            if (fcn_cmp(curSampleRobustness,0))
                vFound = 1;
            end
        else
            if (fcn_cmp(map2line(curSampleRobustness),0))
                vFound = 1;
            end
        end
    end

end %% Function
