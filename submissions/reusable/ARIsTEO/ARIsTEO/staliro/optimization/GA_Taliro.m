% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% GA_Taliro - Performs stochastic optimization using Genetic Algorithms.
% This is a wrapper for calling the Matlab GA optimization algorithm.
%
% USAGE:
% [run, history] = GA_Taliro(inpRanges,opt)
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
% See also: staliro, staliro_options, GA_Taliro_parameters

% (C) 2010, Georgios Fainekos, Arizona State University

function [run,history] = GA_Taliro(InpRange,opt)

assert(opt.varying_cp_times==0 || opt.varying_cp_times==2, ' GA_Taliro does not currently support varying_cp_times==1. For variable times for the control points use option varying_cp_times==2.');

if ~strcmp(opt.taliro_metric,'none') && opt.map2line==0
    error('S-Taliro: Currently GA does not support hybrid distance values. Turn option "map2line" on.');
end

if opt.falsification==0
    error('S-Taliro: Currently GA does not support minimization.');
end

if nargout>1
    error('S-Taliro: Currently GA does not support histories.');
end

if opt.n_workers>1
    error('S-Taliro: Currently GA does not support parallel computation.');
end

if opt.search_space_constrained.constrained
    A_ineq = opt.search_space_constrained.A_ineq;
    B_ineq = opt.search_space_constrained.b_ineq;
else
    A_ineq = [];
    B_ineq = [];
end

% Initialize outputs
run = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history = struct('rob',[],'samples',[],'cost',[]);

ga_options = opt.optim_params.ga_options;
LenInpRange = InpRange(:,2)-InpRange(:,1);
matric = [InpRange(:,1)+LenInpRange*0.1 InpRange(:,2)-LenInpRange*0.1]';
ga_options = gaoptimset(ga_options,...
    'PopInitRange',matric,...
    'FitnessLimit',0,...
    'UseParallel',0,...
    'Vectorized','off');
if opt.dispinfo>=1
    ga_options = gaoptimset(ga_options,'Display','iter');
end

[ga_samples,ga_rob,exitflag,ga_Cyc] = ga(@Compute_Robustness,size(InpRange,1),A_ineq,B_ineq,[],[],InpRange(:,1),InpRange(:,2),[],ga_options);

if exitflag>=0
    run.bestCost = ga_rob;
    run.bestRob = ga_rob;
    run.nTests = ga_Cyc.funccount;
    run.bestSample = ga_samples';
    run.falsified = ga_rob<=0;
else
    run.bestCost = inf;
    run.bestRob = inf;
    run.nTests = gaoptimget(ga_options,'PopulationSize')*gaoptimget(ga_options,'Generations');
    run.bestSample = ga_samples';
    run.falsified = 0;
end

end    

