% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Class definition for STL/MITL Debugging and Vacuity Aware Falsification
% 
% vacuity_param = vacuity_parameters;
%  
%
% obj.optimizer_Stage1_VAF;
%   This is the option for specifying the optimization algorithm for Stage 1
%   of the Vacuity Aware Falsification (VAF). In Stage 1 of VAF, s-taliro
%   focuses on falsifying the antecedent failure of the request-response
%   specification. For more information refer to 
%   Dokhanchi, et al. "Vacuity Aware Falsification for MTL Request-Response  
%   Specifications", CASE 2017
%  
%
% obj.number_of_runs;
%   This is the option for setting the number of iterations of the main
%   algorithm of Vacuity Aware Falsification (VAF). The default value is 1.
%   Each run of VAF algorithm, considers Stage 1 and Stage 2 of the VAF
%   flow. For more information See Fig. 2 and Algorithm 1 of the paper:
%   Dokhanchi, et al. "Vacuity Aware Falsification for MTL Request-Response  
%   Specifications", CASE 2017.
%
%
% obj.use_LTL_satifiability;
%   This is the option for enabling LTL satisfiability if the modified 
%   formula contains Eventually or Always only temporal operation. The
%   default value is 0. If use_LTL_satifiability set to 1, then the LTL
%   satisfiability checker runs before MITL SAT solver.
%   
%   Note: This option needs NuSMV to be installed in the system. Type  
%   "help setup_vacuity" for more information.
%

% (C) 2018, Adel Dokhanchi, Arizona State University

classdef vacuity_parameters
    
    properties
        optimizer_Stage1_VAF;
        number_of_runs;
        use_LTL_satifiability;
    end
    
    methods        
        function obj = VAF_parameters(varargin)
            obj.optimizer_Stage1_VAF = '';
            obj.number_of_runs = 1;
            obj.use_LTL_satifiability = 0;
        end
    end
end

        