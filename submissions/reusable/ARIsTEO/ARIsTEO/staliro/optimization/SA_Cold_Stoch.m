% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [run, history] = SA_Cold_Stoch(inpRanges,opt)
% SA_Cold_Stoch - Performs stochastic optimization using Simulated Annealing
% with hit and run Monte Carlo sampling where the cost function is the
% robustness of a Metric Temporal Logic formula. It calculates the minimum
% expected robustness value for a stochastic model and the corresponding 
% sample that produces the expected robustness value.
%
% USAGE:
% [run] = SA_Cold_Stoch(inpRanges,opt)
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
%           bestRob : The minimum expected robustness value
%
%           bestSample : The sample in the search space where the minimum
%           expected robustness value lies.
%
%           time: The total running time of each run. This value is set by
%               the calling function.
%
% See also: staliro, staliro_options, SA_Cold_Stoch_parameters

% (C) 2013, Bardh Hoxha, Arizona State University
% (C) 2015, Georgios Fainekos, Arizona State University

global staliro_mtlFormula;
global staliro_Predicate;
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_opt;
global staliro_ParameterIndex;
global staliro_Polarity;
global staliro_InputModel;
global staliro_InputModelType;

% INPUTS:
[nInputs, ~] = size(inpRanges);
nSamples = opt.optim_params.n_tests; % The total number of tests to be executed
sa_param = opt.optim_params.sa_params;
cold_param = opt.optim_params;

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

% Initialize outputs
run = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history = struct('rob',[],'samples',[],'cost',[]);

% Adaptation parameters
dispAdap = 1+sa_param.dispAdap/100;

% Algorithm parameters
% Set the J bound
J = cold_param.J_bound;
% Set the delta constant
delta = cold_param.delta;
% Set the adjustment parameter for the squashing function
logAdjParam = cold_param.logAdjParameter;
nTrials = 0;
nAccepts = 0;
curVal = zeros(J,1);

% Set acceptance condition to the Metropolis-Hastings acceptance condition
fcn_cmp = @MHAccept;

%% Initialize optimization
if opt.search_space_constrained.constrained
    curSample = getNewSampleConstrained(sampleSpace);
else
    curSample = (inpRanges(:,1)-inpRanges(:,2)).*rand(nInputs,1)+inpRanges(:,2);
end
if ~isempty(sa_param.init_sample)
    assert(length(curSample)==length(sa_param.init_sample),' SA_Taliro : The proposed initial sample in params.init_sample does not have correct length');
    curSample = sa_param.init_sample;
end

%code for parallel simulations
gls = {staliro_mtlFormula, staliro_Predicate , staliro_SimulationTime, staliro_InputBounds, temp_ControlPoints,staliro_dimX, staliro_opt, staliro_ParameterIndex,staliro_Polarity, staliro_InputModel, staliro_InputModelType};
parfor jj = 1 : J
    [curVal(jj,1)] = globalBridge(gls, curSample);
end

%squashing function to get values from 0 to 1
boundCurVal(:,1) = 1./(1+exp(curVal./logAdjParam));
%meanCost = mean(curVal);
boundCurValDelta = boundCurVal + delta;

prodCost = prod(boundCurValDelta);
prodCostBest = prodCost ;
%bestSample = curSample;

if nargout>1
    history.rob = zeros(nSamples,1);
    history.cost = zeros(nSamples,1);
    history.samples = zeros(nSamples,nInputs);
    
    history.rob(1) = mean(curVal);
    history.cost(1) = prodCostBest;
    history.samples(1,:) = curSample';
end
%% Start optimization
displace = sa_param.dispStart;

for i = 2:nSamples+cold_param.nBurnOutSamples
    tmc = tic;
    nTrials = nTrials + 1;
    
    %Get sample close to the curent sample
    if opt.search_space_constrained.constrained
        curSample1 = getNewSampleConstrained(curSample, sampleSpace, displace);
    else
        curSample1 = getNewSample(curSample,inpRanges,displace);
    end
    
    %code for parallel simulations
    parfor jj = 1 : J      
        [curVal(jj,1)] = globalBridge(gls, curSample1);
    end
    
    %squashing function to get values from 0 to 1
    boundCurVal(:,1) = 1./(1+exp(curVal./logAdjParam));
    boundCurValDelta = boundCurVal + delta;
    prodCost = prod(boundCurValDelta);
    
    %prodCost
    %prodCostBest
    
    if fcn_cmp(prodCost,prodCostBest)
        nAccepts = nAccepts+1;
        prodCostBest = prodCost;
        curSample = curSample1;
        run.bestRob = mean(curVal);
        run.bestSample = curSample1;
        
        %disp([num2str(nAccepts), 'th state update']);
%     else
%         disp('rejecting')
    end
    
    
    if nargout>1
        history.rob(i) = mean(curVal);
        history.cost(i) = prodCost;
        history.samples(i,:) = curSample1';
    end
    
    if (mod(nTrials,50) == 0)
        acRatio=nAccepts/nTrials;
        if (acRatio > sa_param.acRatioMax)
            %% reduce beta - Increase displacement
            displace = displace*dispAdap;           
            nTrials = 0;
            nAccepts = 0;
        elseif (acRatio < sa_param.acRatioMin)
            displace = displace/dispAdap;
            nTrials = 0;
            nAccepts = 0;
        end
        if (displace >= sa_param.maxDisp)
            displace = sa_param.maxDisp;
        end
        if (displace <= sa_param.minDisp)
            displace = sa_param.minDisp;
        end
        
    end
    optime= toc(tmc);
disp(['optimization time',num2str(optime)]);
end

run.bestCost = 'N/A';
run.falsified = 'N/A';
run.paramVal = 'N/A';
run.nTests = nSamples;

%% Auxiliary functions
    function [ p ] = MHAccept( curProb, bestProb )
        % Metropolis-Hastings acceptance condition
        
        prob = min( curProb / bestProb ,1 );
        random = rand(1,1);
        
        if random<prob
            p=1;
        else
            p=0;
        end
    end
end

