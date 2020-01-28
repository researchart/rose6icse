% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Bayesian SMC
%
% USAGE:
% [robustnessValues,nrTests,posteriorMean,confidenceInterval] =
%       bayesianSMC(model,phi,preds,delta,c,alpha,beta)
%
% DESCRIPTION :
%       Bayesian Statistical Model Checking Algorithm estimates the 
%       the probability that a given stochastic model will satisfiy 
%       an MTL formula.
%
%       The algorithm is based on the paper:
%       Zuliani, P.; Platzer, A. & Clarke, E. M. Bayesian statistical model 
%       checking with application to Simulink/Stateflow verification 
%       Proceedings of the 13th ACM International Conference on Hybrid 
%       Systems: Computation and Control, 2010, 243-252
%
% INPUTS :
%          - model        :   string represents a simulink model.
%
%                             Ex: model = 'sim_model';
%
%          - phi          :   Formula to falsify, should be a string.
%                             For the syntax of MTL formulas type
%
%                             help dp_taliro
%
%                             Ex: phi = '!<>_[0,100] []_[0,1]a';
%
%          - preds        :   contains the mapping of the predicates in
%                             the formula. For help defining predicate
%                             mappings type
%
%                             help dp_taliro
%
%          - delta        :   parameter delta for the half size of the
%                             desired interval estimate for p
%
%          - c            :   contains the coverage goal or the
%                             100c percent bayesian interval estimate of p
%
%          - alpha        :   (Optional) parameter alpha for the prior beta
%                             distribution (default value 1)
%
%          - beta         :   (Optional) parameter beta for the prior beta
%                             distribution (default value 1)
%
% OUTPUTS
%       - robustnessValues:   contains the array of robsutness values 
%                             calculated throughout the process
%
%       - nrTests         :   contains the number of tests conducted to 
%                             achieve the required coverage goal c
%
%       - posteriorMean   :   contains the mean of the posterior
%                             distribution
%
%       - confidenceInt   :   contains the confidence interval

% (C) 2012, Bardh Hoxha, Arizona State University

% Future modifications to consider:
%   1) Check against a level of robustness epsilon instead of zero
%   2) Use s_taliro compute robustness function so we can use all the
%      simulation engines 

function [robustnessValues,n_tests,posteriorMean,confidenceInt] = ...
    bayesianSMC(model,phi,preds,delta,c,alpha,beta)

    if exist('alpha','var')==0
        alpha=1;
    end
    if exist('beta','var')==0
        beta=1;
    end

    n_tests = 0; % total number of tests 
    s_tests = 0; % number of successfull tests  

    % max number of tests (make a parameter in the future)
    max_n_tests = 50000;
    robustnessValues = zeros(max_n_tests,1);
    
    for i=1:max_n_tests
     
       [t,~,y] = sim(model);
       robustnessValues(i) = dp_taliro(phi,preds,y,t);
       n_tests = n_tests+1;                    
       
       if robustnessValues(i)>0     % if the robustness value is within bounds 
           s_tests = s_tests+1;     % increase the number of successfull tests
       else
           disp(['Nonpositive robustness found at test : ',num2str(i)]);
       end
       
       p_h = (s_tests+alpha)/(n_tests+alpha+beta);      % calculates the mean of the posterior distribution
       T = [p_h - delta,p_h + delta];
       
       if T(1,2) > 1 
           T = [1-2*delta,1];
       else if T(1,1) < 0
               T = [0,2*delta];
           end
       end
       
       gamma = betacdf(T(1,2),s_tests+alpha,n_tests-s_tests+beta)-betacdf(T(1,1),s_tests+alpha,n_tests-s_tests+beta);

       if gamma >= c
           robustnessValues(n_tests+1:end) = [];
           posteriorMean = p_h;
           confidenceInt = T;
           break;
       end
    end
    
end

        