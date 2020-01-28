% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ results ] = SDA_Taliro(inpRanges,opt)
% RGDA - Robustness Guided Parameter Falsification Domain Algorithm based on
% Algorithm 2 in the STTT paper: <a href="matlab: web('http://arxiv.org/abs/1512.07956')">Mining Parametric Temporal Logic Properties in 
% Model Based Design for Cyber-Physical Systems</a>.
%
% USAGE:
% [run] = SDA_Taliro(inpRanges,opt)
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
% See also: staliro, staliro_options, SDA_Taliro_parameters
%
% (C) 2015, Bardh Hoxha, Arizona State University

global staliro_parameter_list;
global staliro_Parameter;

params = opt.optim_params;

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

%% Initialize outputs and variables
results = struct('polyhedron',[],'listOfKnees',[], 'polarity',[],  'time',[]);
P = Polyhedron([]);
nr_params = length(find(staliro_parameter_list>=2));
param_range = vertcat(staliro_Parameter.range);
countKneeGenFailure = 0;
terminationCondition = 0;
kneeGenFailureMax = params.kneeGenFailureMax;
paramSpacePoly = Polyhedron([eye(nr_params); -1* eye(nr_params)],[param_range(:,2) ; -1* param_range(:,1)]);
generatedKneesArray = paramSpacePoly.V;
%remove the parameter boundary range from generatedKneesArray
if opt.optimization == 'max' %#ok<*STCMP>
    generatedKneesArray(find(ismember(generatedKneesArray, param_range(:,1)','rows')==1),:)=[]; %#ok<*FNDSB>
else
    generatedKneesArray(find(ismember(generatedKneesArray, param_range(:,2)','rows')==1),:)=[];
end

%% initialize optimization
if opt.optimization == 'max'
    normCurSampleParam = zeros(nr_params,1);
else
    normCurSampleParam = ones(nr_params,1);
end
if opt.search_space_constrained.constrained
    curSample = getNewSampleConstrained(sampleSpace);
else
    curSample = getNewSample(inpRanges);
end
curSample(end - nr_params + 1:end) = normCurSampleParam;

while terminationCondition == 0 
    paramSpacePoly = Polyhedron([eye(nr_params); -1* eye(nr_params)],[param_range(:,2) ; -1* param_range(:,1)]);
    opt.optim_params.init_sample = curSample;
    
    disp('--------------------------');
    disp('Attempt to generate knee...');
    disp('--------------------------');
    
    % run optimization algorithm begining with curSample and searching in
    % one direction
    [getResults, ~] = feval(params.optimization_solver,inpRanges,opt);
    
    % scale back results from normalized to original ranges
    unscaledParams =  (param_range(:,2) - param_range(:,1)) .* getResults.paramVal + param_range(:,1);
    generatedKneesArray(end+1,:) = unscaledParams'; %#ok<*AGROW>
    
    if getResults.bestRob <= 0
        %case when parameter values found are not in P (parameter
        %falsification domain)
        if ~P.contains(unscaledParams)
            %Append P with new polyhedron
            if isequal(opt.optimization,'max')
                P(end+1) = Polyhedron([eye(nr_params); -1* eye(nr_params)],[unscaledParams ; -1* param_range(:,1)]);
            else
                P(end+1) = Polyhedron([eye(nr_params); -1* eye(nr_params)],[param_range(:,2) ; -1*unscaledParams]);
            end
            disp('Knee generated...');
            disp('Knee generation count reset to 0...');
            results.listOfKnees{end+1} = unscaledParams';
            [P, results] = removeDominatedKnees(P,results);
            
            for ii=2:size(P,2)
                %subtract the new polyhedrons from the original parameter
                %space
                paramSpacePoly = mldivide(paramSpacePoly,P(ii));
            end
            % complementP represents the set of parameters for which falsification
            % is not found, the complement of set P.
            complementP = paramSpacePoly;
            %generate knees from complementP
            newKnees = vertcat(complementP.V);
            %remove unecessary knees
            newKnees = removeUneccessaryKnees(newKnees, generatedKneesArray, param_range);
            oldKnees = newKnees;

            pause(0.1);
            %reset Knee Generation Failure counter
            countKneeGenFailure = 0;
                
        else
            %failure to generate usefull knee, increase Knee Generation Failure counter
            countKneeGenFailure = countKneeGenFailure + 1;
            disp(['Knee generation attempt: ',num2str(countKneeGenFailure),'/',num2str(kneeGenFailureMax)]);
            %terminate if no usefull knee is generated in max number of
            %attempts
            if countKneeGenFailure >= kneeGenFailureMax
                terminationCondition = 1;
            end
            newKnees = oldKnees;
        end
    else
        %failure to generate usefull knee, increase Knee Generation Failure counter
        countKneeGenFailure = countKneeGenFailure + 1;
        disp(['Knee generation attempt: ',num2str(countKneeGenFailure),'/',num2str(kneeGenFailureMax)]);
        %terminate if no usefull knee is generated in max number of
        %attempts
        if countKneeGenFailure >= kneeGenFailureMax
            terminationCondition = 1;
        end
        newKnees = oldKnees;        
    end
    
    sz = size(newKnees,1);
    %no knees available, terminate
    if(sz < 1)
        terminationCondition = 1;
    else
    %randomly set the next inital sample from set of knees
    if opt.search_space_constrained.constrained
        curSample = getNewSampleConstrained(sampleSpace);
    else
        curSample = getNewSample(inpRanges);
    end
    normCurSample = (newKnees(randperm(sz,1),:)'-param_range(:,1))./(param_range(:,2)-param_range(:,1));
    curSample(end - nr_params + 1:end) = normCurSample;
    end
end
P(1) = [];
results.polyhedron = P;

    % function removes dominated knees
    function [polytope, knees] = removeDominatedKnees(poly, res)
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
            disp([num2str(length(toRemove)), ' dominated knee(s) removed...']);
        end
        polytope = poly;
        knees = res;
    end

    % function used to remove knees that are generated as artifacts of the
    % polyhedron functions that are not usefull.
    function [ nK ] = removeUneccessaryKnees(nKnees,gKA, p_range)
        %change to single type to avoid cases where division causes issues
        %in equality checking
        nKnees = single(nKnees);
        gKA = single(gKA);
        for i = 1:size(gKA,1)
            nKnees(find(ismember(nKnees, gKA(i,:),'rows')==1),:)=[];
        end
        toRem = [];
       % hold on;            scatter3(nKnees(:,1),nKnees(:,2),nKnees(:,3),'g')
        %remove invalid knees
        for i = 1:size(nKnees,1)
            for j = 1:size(nKnees,1)
                if i~=j
                    if opt.optimization == 'max'
                        if all(nKnees(i,:) > nKnees(j,:))
                            toRem = [toRem ; i];
                        end
                    else
                        if all(nKnees(i,:) < nKnees(j,:))
                            toRem = [toRem ; i];
                        end
                    end
                end
            end
        end
        nKnees(toRem,:) = [];
        %hold on;            scatter3(nKnees(:,1),nKnees(:,2),nKnees(:,3),'b')
        toRem = [];        
        %remove knees to close to boundary of parameter range
        if isequal(opt.optimization,'max')
            for i = 1:size(nKnees,1)
                percDistToBoundary = (p_range(:,2)' - nKnees(i,:)) ./ (p_range(:,2)' - p_range(:,1)');
                if min(percDistToBoundary) <= params.tolParamRangeBoundaryKnee
                    toRem = [toRem; i];
                end
            end
            nKnees(toRem,:) = [];
        else
            for i = 1:size(nKnees,1)
                percDistToBoundary = (nKnees(i,:) - p_range(:,1)') ./ (p_range(:,2)' - p_range(:,1)');
                if min(percDistToBoundary) <= params.tolParamRangeBoundaryKnee
                    toRem = [toRem; i];
                end
            end
            nKnees(toRem,:) = [];
        end
        %hold on;            scatter3(nKnees(:,1),nKnees(:,2),nKnees(:,3),'magenta')
        toRem = [];        
        %remove knees due to close proximity
        %first normalize nKnees
        normKnees = bsxfun(@minus, nKnees,p_range(:,1)');
        normKnees = bsxfun(@rdivide, normKnees,p_range(:,2)'-p_range(:,1)');
        
        if min(pdist(normKnees,'euclidean')) <= params.tolKneeProximity
            temp = (triu(squareform(pdist(normKnees,'euclidean'))));
            %set lower triangle to Inf
            temp(tril(ones(size(squareform(pdist(normKnees,'euclidean')))),-1) == 1) = Inf;
            %set diagonal to Inf
            temp(1:size(temp,1)+1:size(temp,1)^2) = Inf;
            [ vals, row ] = min(temp);
            for i = 1:length(row)
                if (vals(i) <= params.tolKneeProximity)
                    toRem = [toRem ; row(i)];
                end
            end
        end        
        nKnees(toRem,:) = [];        
        nK = nKnees;
    end
end







