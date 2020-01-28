% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% ACO_Taliro - Performs stochastic optimization using Extended Ant Colony 
% Optimization (EACO). This is a wrapper for calling a mex implementation 
% of EACO.
%
% USAGE:
% [run, history] = ACO_Taliro(inpRanges,opt)
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

% (C) 2010, Georgios Fainekos, Arizona State University

function [run,history] = ACO_Taliro(InpRange,opt)
       
error(' ACO_Taliro : Currently is not supported.')

assert(opt.varying_cp_times==0, ' ACO_Taliro does not currently support variable times for the control points.');

% Initialize outputs
run = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history = struct('rob',[],'samples',[],'cost',[]);

if ~strcmp(opt.taliro_metric,'none') && opt.map2line==0
    error('S-Taliro: Currently ACO does not support hybrid distance values. Turn option "map2line" on.');
end

if opt.falsification==0
    error('S-Taliro: Currently ACO does not support minimization');
end

if nargout>1
    error('S-Taliro: Currently ACO does not support histories');
end

total_cycles = ceil(opt.optim_params.n_tests/opt.optim_params.ants_number);

[rob_ant,~,total_cycles_ant,input_ant] = ant_mex_algo(InpRange,opt.optim_params.ants_number,total_cycles);

run.bestCost = rob_ant;
run.bestRob = rob_ant;
run.nTests = total_cycles_ant;
run.bestSample = input_ant;
run.falsified = rob_ant <= 0;

end
