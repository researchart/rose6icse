% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [cost, ind, cur_par, rob, sigData, YT] = Compute_Robustness(input)
% Compute_Robustness - Calls Compute_Robustness_Right appropriately and
% retrieves results depending on whether conformance testing, falsification
% or parameter estimation is being conducted
%
% USAGE
% [cost, ind, cur_par, rob] = Compute_Robustness(input)
%
% INPUTS:
%   input: An n-by-1 array of inputs for which the robustness value
%       is computed
%
% OUTPUTS:
%   cost: cost and rob are the same for falsification problems. cost
%       and rob are different for parameter estimation problems.
%
%   ind: a flag for possible errors
%       = 0 when no problems were detected
%       = -1 when the input signal does not satisfy the constraints
%       (interpolation function does not respect the input signal bounds)
%
%   cur_par: the parameter value
%
%   rob: the robustness value
%
% (C) 2013, Bardh Hoxha, Arizona State University

global staliro_InputModel;
global staliro_InputModelType;
global staliro_mtlFormula;
global staliro_Predicate;
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_opt;
global staliro_ParameterIndex;
global staliro_Polarity;

warning('off','Simulink:Logging:LegacyModelDataLogsFormat');

%save all the globals in a cell variable
gls = {staliro_mtlFormula, staliro_Predicate , staliro_SimulationTime, staliro_InputBounds, temp_ControlPoints,staliro_dimX, staliro_opt, staliro_ParameterIndex,staliro_Polarity, staliro_InputModel, staliro_InputModelType};

if iscell(input)
    
    %initialize cell arrays
    cost = cell(1, length(input));
    ind = cell(1, length(input));
    cur_par = cell(1, length(input));
    rob = cell(1, length(input));    
    
    %check that the size of the input array is the same as the number of
    %workers
    if length(input) ~= staliro_opt.n_workers
        error('S-Taliro (Internal): The number of workers and the size of the cell array do not match.')
    end
    
    if length(input)>1
        %compute the robustness in parallel. The global bridge function is used
        %to initialize the global variables for each workers' workspace.
        parfor ii = 1:length(input)
            warning('off','Simulink:Logging:LegacyModelDataLogsFormat');
            [cost{ii}, ind{ii}, cur_par{ii}, rob{ii}] = globalBridge(gls, input{ii});
            warning('on','Simulink:Logging:LegacyModelDataLogsFormat');
        end
    else
        warning('off','Simulink:Logging:LegacyModelDataLogsFormat');
        [cost{1}, ind{1}, cur_par{1}, rob{1}, sigData] = Compute_Robustness_Right(staliro_InputModel, staliro_InputModelType, input{1});
        warning('on','Simulink:Logging:LegacyModelDataLogsFormat');
    end
    
else
    
    if (staliro_opt.stochastic == 1) && (staliro_opt.n_workers > 1)
        
        %initialize cell arrays
        cost = cell(1, size(input,2));
        ind = cell(1, size(input,2));
        cur_par = cell(1, size(input,2));
        rob = cell(1, size(input,2));
        
        %compute the robustness in parallel. The global bridge function is used
        %to initialize the global variables for each workers' workspace. In
        %this case the input in an array
        parfor ii = 1:staliro_opt.n_workers
            warning('off','Simulink:Logging:LegacyModelDataLogsFormat');
            %[cost{ii}, ind{ii}, cur_par{ii}, rob{ii}] = globalBridge(gls, input);
            [cost{ii}, ind{ii}, cur_par{ii}, rob{ii}] = globalBridge(gls, input);
            warning('on','Simulink:Logging:LegacyModelDataLogsFormat');
        end
        
    else
        %this is the case when only one worker is utilized
        
        % if the goal is conformance tesing then it is necessary to get the
        % robustness values for both models
        if iscell(staliro_InputModel)
            
            [cost1, ind1, ~, rob1, sigData, YT] = Compute_Robustness_Right(staliro_InputModel{1},staliro_InputModelType{1}, input);
            [cost2, ~, ~, rob2, sigData, YT] = Compute_Robustness_Right(staliro_InputModel{2},staliro_InputModelType{2}, input);
            % calculate cost by taking the absolute value of the difference of both
            % robustness values and adding a buffer of 5, which was selected
            % arbitrarily
            cost = abs(cost2 - cost1);
            ind = ind1;
            cur_par = inf;
            rob = abs(rob2 - rob1);
        else
            [cost, ind, cur_par, rob, sigData, YT] = Compute_Robustness_Right(staliro_InputModel, staliro_InputModelType , input);
        end
    end
end

warning('on','Simulink:Logging:LegacyModelDataLogsFormat');

end
