% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% signal_vacuity will perform the Signal Vacuity Checking which
% checks whether the simulation output satisfies the antecedent failure of
% Metric Temporal Logic (MTL) formulas.
%
% For the theory see the paper:
% Dokhanchi, et al. "Formal Requirement Debugging for Testing and  
% Verification of Cyber-Physical Systems", ACM/TECS 2018
%
%
% USAGE:
% [vacuity ,results, history] = 
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
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change S-Taliro options, 
%       see the <a href="matlab: doc staliro_options">staliro_options help file</a> for each desired property.
%       
%       opt.runs will be set to 1. 
%       opt.runs is the number of runs of the stochastic optimization algorithm.
%
% OUTPUTS
%   - results, history: 
%     For information about results or history type "help staliro".
% 
%
%   - vacuity: a structure with the following fields
%
%     * antecedent_failure: the string of the antecedent failure formula.
%       Antecedent failure is extracted from the Request Response
%       specification. Request response must contain one implication (->)
%       operation in the positive form. For example 
%       phi = '[]_[0,10](REQ -> <>_[0,5] ACK)' is a request response
%       specification. Antecedent failure is a formula that asserts the
%       antecedent of implication (->) never happens. Antecedent failure of
%       phi is as follows: 
%       AF_phi = '[]_[0,10]!(REQ)'
%
%     * sample_index: A vector of indexes from history.samples where the 
%       simulated signal of history.samples are vacuous signals. 
%
%     * robustness: A vector of robustness corresponding to each 
%       sample_index. These robustness values are positive since vacuous
%       signals are the traces which satisfy the antecedent_failure.
%		
% Please send reports for bugs and/or comments for improvements to 
%               fainekos @ asu.edu
%
% See also : stl_debug
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

function [vacuity, results, history] = signal_vacuity(model, init_cond, ...
    input_range, cp_array, phi, preds, TotSimTime, opt)

vacuity=struct('antecedent_failure',[],'sample_index',[],'robustness',[]);

opt.runs=1;

[results,history] = staliro(model,init_cond,input_range,cp_array,phi,preds,TotSimTime,opt);

mitl= stl_debug(phi,preds,opt,'antecedent_failure');
vacuity.antecedent_failure=mitl;
inputModelType = determine_model_type(model);
if strcmp(inputModelType, 'function_handle')
    model1 = staliro_blackbox(model);
else
    model1 = model;
end

s=size(history.samples);
for i=1:s(1)
    positive=0;
    mtlFormula=vacuity.antecedent_failure;
    warning('off','all');
    [T1,XT1,YT1,inpSig,LT1,CLG,GRD] = SimulateModel(model1, init_cond, input_range, cp_array,history.samples(i,:),TotSimTime,opt);
    
    if opt.spec_space=='Y'
        if( isempty(CLG)==1)
            [rob] = dp_taliro(mtlFormula,preds,YT1,T1);
        elseif( isempty(GRD)==1)
            [rob] = dp_taliro(mtlFormula,preds,YT1,T1,LT1,CLG);
        else
            [rob] = dp_taliro(mtlFormula,preds,YT1,T1,LT1,CLG,GRD);
        end
    elseif opt.spec_space=='X'
        if( isempty(CLG)==1)
            [rob] = dp_taliro(mtlFormula,preds,XT1,T1);
        elseif( isempty(GRD)==1)
            [rob] = dp_taliro(mtlFormula,preds,XT1,T1,LT1,CLG);
        else
            [rob] = dp_taliro(mtlFormula,preds,XT1,T1,LT1,CLG,GRD);
        end
    else
         error('No output trajectory!');
    end

    if(rob > 0)
            positive=1;
    end
    
    if positive==1
        vacuity.sample_index=[vacuity.sample_index;i];
        vacuity.robustness=[vacuity.robustness;rob];
    end
     

end


end
