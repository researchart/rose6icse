% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ params ] = reqMining(inpArray,cp_array,staliro_opt, monotonicity )
%REQMINNING function that uses a loop to determine generate new
%trajectories, conduct binomial search to synthesize parameters, and then
%run falsification to confirm the parameters synthesized

global staliro_InputModel;
global staliro_mtlFormula;
global staliro_Predicate;
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_ParameterIndex;
global staliro_parameter_list;
global staliro_inpRangeUnscaled;

% Create sample space polyhedron
if staliro_opt.search_space_constrained.constrained
    input_lb = inpArray(:, 1);
    input_ub = inpArray(:, 2);
    input_A = staliro_opt.search_space_constrained.A_ineq;
    input_b = staliro_opt.search_space_constrained.b_ineq;
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

monotony = monotonicity;
sz = size(staliro_ParameterIndex,2);
parRange = staliro_inpRangeUnscaled(end-sz+1:end,:);
pred_tmp = staliro_Predicate;
parameter_list = staliro_parameter_list;
parameter_index = staliro_ParameterIndex;
if opt.search_space_constrained.constrained
    curSample = getNewSampleConstrained(sampleSpace);
else
    curSample = getNewSample(inpArray);
end
XPoint = curSample(1:staliro_dimX);
nb_ControlPoints = temp_ControlPoints';

if staliro_opt.parameterEstimation > 0
    UPoint = curSample(staliro_dimX+1:end - size(staliro_ParameterIndex,2));
else
    UPoint = curSample(staliro_dimX+1:end);
end

[hs, ~] = systemsimulator(staliro_InputModel, XPoint, UPoint, staliro_SimulationTime, staliro_InputBounds, nb_ControlPoints);

trajs{1} = hs;
[params, rob] = paramBin(trajs,monotony,parRange,sz,parameter_list,parameter_index);

iter = 1;
iter_max = 100;
while iter<=iter_max
    
    clc;
    disp(num2str(iter))
    disp(num2str(params))
    
    for ii=1:size(parameter_index,2)
        if parameter_list(parameter_index(ii)) == 2
            pred_tmp(parameter_index(ii)).value = params(ii);
        elseif parameter_list(parameter_index(ii)) == 3
            pred_tmp(parameter_index(ii)).value = params(ii);
            pred_tmp(parameter_index(ii)).b = params(ii);
        else
            error('Staliro: Parameter setting error, check the predicate settings.');
        end
    end
    
    staliro_opt.falsification = 1;
    staliro_opt.parameterEstimation = 0;
    staliro_opt.optimization = 'min';
    
    clearvars -global staliro_Predicate
    staliro_Predicate =  pred_tmp;
    [results] =  staliro(staliro_InputModel,[],staliro_InputBounds,cp_array,staliro_mtlFormula,pred_tmp,staliro_SimulationTime,staliro_opt);
    
    [hs, ~] = systemsimulator(staliro_InputModel, XPoint, results.run(1).bestSample, staliro_SimulationTime, staliro_InputBounds, nb_ControlPoints);
    
    trajs{iter+1} = hs; %#ok<AGROW>
    
    ifalse = find(results.run.bestRob<0); %#ok<EFIND>
    
    if ~isempty(ifalse)
        [params, rob] = paramBin(trajs,monotony,parRange,sz,parameter_list,parameter_index);
    else
        fprintf(['\nStopped. Final robustness: ' num2str(min(rob))]);
        fprintf('\n');
        return;
    end
    iter=iter+1;
end
fprintf('\nStopped after max number of iterations.\n');

end

