% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [results] = RGDA_Taliro(inpRanges,opt)

% RGDA - Robustness Guided Parameter Falsification Domain Algorithm based on
% Algorithm 1 in the STTT paper: <a href="matlab: web('http://arxiv.org/abs/1512.07956')">Mining Parametric Temporal Logic Properties in 
% Model Based Design for Cyber-Physical Systems</a>.
%
% USAGE:
% [run] = RGDA_Taliro(inpRanges,opt)
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
%   - results: a structure with the following fields
%
%       - polyhedron: stores a polyhedron (requires MPT toolbox to be
%                     installed) of the falsification domain in the 
%                     parameter space.
%
%       - listOfKnees: cell array of knees discovered by the parameter
%                      falsification domain algorithms.
%
%		- polarity: indicates whether the specification has positive or 
%                   negative polarity. This value is set by
%                   the calling function. 
%
%       - time: time taken to run the algorithm. This value is set by
%               the calling function.
%
% See also: staliro, staliro_options, RGDA_Taliro_parameters
%
% (C) 2015, Bardh Hoxha, Arizona State University

global staliro_parameter_list;
global staliro_Parameter;

params = opt.optim_params;

% Initialize outputs and variables
results = struct('polyhedron',[],'listOfKnees',[], 'polarity',[],  'time',[]);
P = Polyhedron([]);
nr_params = length(find(staliro_parameter_list>=2));
param_range = vertcat(staliro_Parameter.range);

% begin tests
for ii = 1:opt.runs
    % generate random weights and normalize
    randomNumbers = rand(1,nr_params);
    sumOfNumbers = sum(randomNumbers);
    normalizedRandomNumbers = randomNumbers / sumOfNumbers;
    opt.polarity_weight = normalizedRandomNumbers;
    
    disp('--------------------------');
    disp(['Attempt ', num2str(ii),'/',num2str(opt.runs),' to generate knee...']);
    disp('--------------------------');
    
    % run optimization algorithm
    [getResults, ~] = feval(params.optimization_solver,inpRanges,opt);
    
    % scale back results from normalized to original ranges
    unscaledParams =  (param_range(:,2) - param_range(:,1)) .* getResults.paramVal + param_range(:,1);

    if getResults.bestRob <= 0
        if ~P.contains(unscaledParams)
            if isequal(opt.optimization,'max')
                P(end+1) = Polyhedron([eye(nr_params); -1* eye(nr_params)],[unscaledParams ; -1* param_range(:,1)]);
            else
                P(end+1) = Polyhedron([eye(nr_params); -1* eye(nr_params)],[param_range(:,2) ; -1*unscaledParams]);
            end
            disp('Knee generated...');
            results.listOfKnees{end+1} = unscaledParams';
            [P, results] = removeUnecessaryKnees(P,results);
        end
    end
end
P(1) = [];
results.polyhedron = P;

    % function removes redundant knees
    function [polytope, knees] = removeUnecessaryKnees(poly, res)
        
        disp('Analyzing set of knees...');
        
        toRemove = [];
        for kk = 1:length(res.listOfKnees)-1
            if isequal(opt.optimization,'max')
                if all((res.listOfKnees{kk} <= res.listOfKnees{end}) == 1)
                    toRemove(end+1) = kk;                  
                end
            else
                if all((res.listOfKnees{kk} >= res.listOfKnees{end}) == 1)
                    toRemove(end+1) = kk;
                end
            end
        end
      
        res.listOfKnees(toRemove) = [];
        poly(toRemove+1) = [];
        
        if ~isempty(toRemove) 
            disp([num2str(length(toRemove)), ' redundant knee(s) removed...']);
        end
        
        polytope = poly;
        knees = res;
    end

end







