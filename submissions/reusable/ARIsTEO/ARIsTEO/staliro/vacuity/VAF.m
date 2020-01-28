% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% VAF will perform the Vacuity Aware Falsification which improves the
% falsification of Request Response Metric Temporal Logic (MTL) formulas.
%
% For the theory see the paper:
% Dokhanchi, et al. "Vacuity Aware Falsification for MTL Request-Response 
% specifications", IEEE CASE 2017.
%
%
% USAGE:
% [results_pref, results_suff, n_fals] = 
% signal_vacuity(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, opt)
%
% INPUTS :
%   The inputs are the same with s-taliro inputs:
%   - model : Can be of type function handle, Blackbox class object,
%       string of the name of the Simulink model or hybrid automaton.
%   - init_cond : A hyper-rectangle that holds the range of the initial 
%       conditions.
%   - input_range : The constraints for the parametrization of the input
%       signal space.
%   - cp_array : contains the control points that parametrize each input 
%       signal. 
%   For more information about model, init_cond, input_range, cp_array run:
%       >>help staliro
%
%
%
%   - phi : The Request_Response MTL formula to find the list of vacuous 
%       signals that satisfy the antecedent failure. phi should be a string. 
%       For the syntax of MTL formulas type "help stl_debug".
%                               
%       Example: 
%           phi = '[]_[0,10](REQ -> <>_[0,5] ACK)'
%
%
%   - preds : Contains the mapping of the atomic propositions in the formula to
%       predicates over the state space or the output space of the model. For 
%       help defining predicate mappings type "help stl_debug".
%
%
%   - TotSimTime : total simulation time.
%
%   - opt : s-taliro options. opt should be of type "staliro_options". 
%       For instructions on how to change S-Taliro options, 
%       see the <a href="matlab: doc staliro_options">staliro_options help file</a> for each desired property.
%       
%     NOTE 1:
%       opt.vacuity_param.optimizer_Stage1_VAF must contain the name of the
%       optimization algorithm for Stage 1 of the Vacuity Aware Falsification (VAF).
%       See <a href="matlab: doc staliro_options/optimization_solver">optimization help file</a> for the options of optimization. 
%       For more information about the VAF theories, see Fig. 2 of CASE 2017 paper.
%
%     NOTE 2:
%       opt.vacuity_param.number_of_runs must contain the name of iteration
%       of the main algorithm of Vacuity Aware Falsification (VAF). For more 
%       information about the VAF theories, see Algorithm 1 of CASE 2017 paper.
%                                                                          
%                                                                          
% OUTPUTS
%   - results_pref: 
%     This contains the experimental results of the Stage 1 of the Vacuity 
%     Aware Falsification (VAF). The size of results_pref is equal to 
%     opt.vacuity_param.number_of_runs.
%     For information about the format of results_pref type "help staliro".
%
%   - results_suff: 
%     This contains the experimental results of the Stage 2 of the Vacuity 
%     Aware Falsification (VAF) if the Antecedent of request response 
%     specification is satisfied. The size of results_suff is less than 
%     opt.vacuity_param.number_of_runs.
%     For information about the format of results_suff type "help staliro".
%
%   - n_fals: 
%     Shows the number of successful runs of Vacuity Aware Falsification (VAF).
% 
%		
% Please send reports for bugs and/or comments for improvements to 
%               fainekos @ asu.edu
%
% See also : stl_debug, signal_vacuity
%
% (C) 2018, Adel Dokhanchi, Arizona State University
% 
% This program is free software; you can redistribute it and/or modify   
% it under the terms of the GNU General Public License as published by   
% the Free Software Foundation; either version 2 of the License, or      
% (at your option) any later version.                                    
%                                                                        
% This program is distributed in the hope that it will be useful,        
% but WITHOUT ANY WARRANTY; without even the implied warranty of         
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          
% GNU General Public License for more details.                           
%                                                                        
% You should have received a copy of the GNU General Public License      
% along with this program; if not, write to the Free Software            
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [results_pref,results_suff,n_fals] = VAF(model, init_cond,... 
    input_range, cp_array, phi, preds, simTime, optStage1)

% Exract Antecedent Failure
phi_AF= stl_debug(phi,preds,optStage1,'antecedent_failure');

results_pref = [];
results_suff = [];
n_fals = 0;
inputModelType = determine_model_type(model);
if strcmp(inputModelType, 'function_handle')
    model1 = staliro_blackbox(model);
else
    model1 = model;
end
        
optStage2 = optStage1;
optStage1.optimization_solver = optStage1.vacuity_param.optimizer_Stage1_VAF;
optStage1.optim_params.n_tests = optStage2.optim_params.n_tests;
for i = 1:optStage1.vacuity_param.number_of_runs
    %% Run first for antecedent
    disp(' ')
    disp(['Running S-TaLiRo for VAF Stage 1 with ',num2str(optStage1.optim_params.n_tests), ' number of tests ...'])
    disp(['Antecedent Failure : ',phi_AF])
    [results1, history1] = staliro(model1,init_cond,input_range,cp_array,phi_AF,preds,simTime,optStage1);
    results_pref = [results_pref results1];
    if results1.run(results1.optRobIndex).falsified
        [T1,XT1,YT1,inpSig,LT1,CLG,GRD] = SimulateModel(model1, init_cond, input_range, cp_array,results1.run(results1.optRobIndex).bestSample,simTime,optStage1);
        if isempty(XT1)==1
            if( isempty(CLG)==1)
                [rob1,aux1] = dp_taliro(phi_AF,preds,YT1,T1);
                rob2 = dp_t_taliro(phi_AF,preds,YT1,T1);
            elseif( isempty(GRD)==1)
                [rob1,aux1] = dp_taliro(phi_AF,preds,YT1,T1,LT1,CLG);
                rob2 = dp_t_taliro(phi_AF,preds,YT1,T1,LT1,CLG);
            else
                [rob1,aux1] = dp_taliro(phi_AF,preds,YT1,T1,LT1,CLG,GRD);
                rob2 = dp_t_taliro(phi_AF,preds,YT1,T1,LT1,CLG,GRD);
            end
        else
            if( isempty(CLG)==1)
                [rob1,aux1] = dp_taliro(phi_AF,preds,XT1,T1);
                rob2 = dp_t_taliro(phi_AF,preds,XT1,T1);
            elseif( isempty(GRD)==1)
                [rob1,aux1] = dp_taliro(phi_AF,preds,XT1,T1,LT1,CLG);
                rob2 = dp_t_taliro(phi_AF,preds,XT1,T1,LT1,CLG);
            else
                [rob1,aux1] = dp_taliro(phi_AF,preds,XT1,T1,LT1,CLG,GRD);
                rob2 = dp_t_taliro(phi_AF,preds,XT1,T1,LT1,CLG,GRD);
            end
        end
        idx1 = find(inpSig(:,1)>(T1(aux1.i)+rob2.pt),1);
        idx2 = find(T1>(T1(aux1.i)+rob2.pt),1);
        % Reduce the total number of tests by the number already executed
        if strcmp(optStage2.optimization_solver,'CE_Taliro')==1
            optStage2.optim_params.n_tests = floor((optStage2.optim_params.n_tests-results1.run(results1.optRobIndex).nTests-1)/...
            optStage2.optim_params.num_iteration)*optStage2.optim_params.num_iteration;
        else
            optStage2.optim_params.n_tests = optStage1.optim_params.n_tests-results1.run(results1.optRobIndex).nTests-1;
        end

        if length(optStage2.interpolationtype)==1
            pref_sig = inpSig(1:idx1,:);
            optStage2.interpolationtype = {{pref_sig, optStage2.interpolationtype{1}}};
        else
            for ii = 1:length(optStage2.interpolationtype)
                pref_sig = [inpSig(1:idx1,1) inpSig(1:idx1,ii+1)];
                optStage2.interpolationtype{ii} = {pref_sig,  optStage2.interpolationtype{ii}};
            end
        end

        % Remark: empty initial conditions since we need to fix to the initial 
        % conditions from the previous search
%         model.init.h0 = XPoint; % pass the previous initial conditions through the model
        disp(' ')
        disp(['Running S-TaLiRo for VAF Stage 2 with ',num2str(optStage2.optim_params.n_tests), ' number of tests ...'])
        disp(['Specification : ',phi])
        [results2, history2] = staliro(model1,init_cond,input_range,cp_array,phi,preds,simTime,optStage2);
        results2.run.nTests = results2.run.nTests+results1.run(results1.optRobIndex).nTests+1;
        results_suff = [results_suff results2];
        
        if results2.run.falsified
            n_fals = n_fals+1;
        end
    end
end
end