% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Class definition for Structural Coverage parameters 
% 
% StrlCov_params = StrlCov_parameters
%
% opt.multiHAs;
%   This is an option for specifying whether the structural coverage is 
%   applied to a single Hybrid Automata: (multiHAs=0) or multiple hybrid 
%   automatas:(multiHAs=1). In multiple hybrid automatas we can use model 
%   instrumentation to extract the HAs from discrete blocks such as 
%   switches blocks. In single hybrid automata the coverage algorithm is 
%   applied on the user defined hybrid automata, and no instrumentation is 
%   considered. The default value of this option is 0.
%   
%
% opt.nLocUpdate;
%   This value sets the number of iterations of the main loop of structural 
%   coverage. "nLocUpdate" specifies how many times the structural coverage
%   updates the MTL specification formula based on the observed 
%   states/modes and run the falsification algorithm. This value can be 
%   overwritten by other options. The default value of this option is 1.
%
% opt.coverageAlgorithm;
%	This option is defined to specify the heuristic algorithm that is used 
%	for structural coverage. This option should be set to the default value 
%   of: 'brute_force' since the algorithm which is implemented in this 
%   project is intended to force the system to visit the unvisited or less 
%   visited modes. Therefore, this is the only option in the current 
%   implementation and it does not have other alternatives.
%
% obj.pathCoverage;
%	This option specifies whether the state coverage is considered:
%   (pathCoverage=0) or whether the path coverage is considered:
%   (pathCoverage=1) 
%   Since the path coverage is not implemented so far, this value must be 
%   set to 0 which is the default value.
%
% obj.locSearch;
%   This option defines the method to choose the mode/location predicate
%   for the iterations of the algorithm. If it is defined as 'random', the
%   mode/location predicate is chosen randomly from unobserved 
%   modes/locations. If it is defined as 'specific', the mode/location 
%   predicate is pre-assigned by the user with the other parameter 
%   (specificLoc). The default value of this option is 'random'.
%                                                                          
% obj.specificLoc;
%   When the "locSearch" parameter is defined as 'specific', the option of 
%   "specificLoc" contains the list of modes that are suggested by the user
%   to consider for the mode/location predicate. In this case, the 
%   model/location predicate is fixed and will not change by the algorithm. 
%   The size of list given in "specificLoc" overrides value of 
%   nLocUpdate's option because the algorithm will not try the other MTL
%   specifications.
%   
% obj.numOfParallel;
%   This option specifies the number of parallel executions of staliro for
%   each iteration of functional coverage. This value should alway be 1.
%    
% obj.numOfMultiHAs;
%   This is an array with the size the number of Hybrid Automatons, and it
%   contains the number of location/state for each hybrid automaton. This 
%   array is not assigned by the user and systemsimulator specifies the 
%   array based on the instrumented model (Black Box).
%
% obj.chooseBestSample;
%   This option specifies whether history of modes be updated based on all 
%   the test/simulations of staliro where (chooseBestSample=0) or only
%   based on the best sample of staliro (chooseBestSample=1). 
%   Its default value is 0.
%
% obj.locationEncoding;
%   This specifies how the system modes are considered based on the 
%   discrete blocks. This value is ignored when we have (multiHAs=0).
%   When \texttt{multiHAs=1} 
%   We have two options for "locationEncoding":
%
%	locationEncoding='independent': This option is used in order the
%   algorithm to consider each discrete block individually for choosing the
%   mode predicate. In this option, algorithm can focus on one switch with 
%   minimum visited mode and ignores the other switches.
%   In this mode algorithm incrementally considers more switches with 
%   minimum mode and ignore the rest of the switches and continue in that 
%   pattern until all the combinations are tried.
%
%  	locationEncoding='combinatorial': This option is used in order to 
%   algorithm consider the global mode of the system, but not individual 
%   discrete blocks. When the "locationEncoding" is 'combinatorial', the 
%   number of states of the system is exponential to the number of discrete
%   blocks; therefore, algorithm focuses on whether each combination is 
%   visited or not in the system simulation, and chooses the mode predicate
%   randomly among the unvisited mode combinations.
%   
%   "locationEncoding" will be ignored when user define "locSearch" as 
%   'specific'. The default value of this option is 'combinatorial'.
%
% obj.startUpTime;
%   This value sets the lower bound of the location formula. Its default
%   value is 0. Considering startUpTime we add the location predicate to 
%   the original specification (old_phi) as follows:
%
%   new_phi = old_phi \/ ! <>_[startUpTime,inf) location_predicate
% 
% obj.instumentModel;
%   If this value is 1 the s-taliro will create the BlackBox and the 
%   corresponding instrumented model with new outputs. If it is 0 the 
%   s-taliro use the input model for structural coverage without any change.
%
% obj.modelInitFile
%   This must a .mat file string (provided without extension) input required by model instrumentation to
%   compile the model. This is an optional argument to be provided only
%   simulink model has dependencies to compile.
%   Please refer to model_instrumentation.m for more details.
% obj.exclusionlist
%   cell array of blocks to be excluded from model instrumentation if any.
%   Please refer to model_instrumentation.m for more details.
%   
% Default parameter values:
%
% multiHAs = 0;                        
% nLocUpdate = 1;
% coverageAlgorithm = 'brute_force';
% pathCoverage = 0;
% locSearch='random';
% specificLoc=0;
% numOfParallel=1;
% numOfMultiHAs=[];
% chooseBestSample=0;
% locationEncoding = 'combinatorial';
% instumentModel = 0;
% modelInitFile = '';
% exclusionlist = {};
                             
% To change the default values to user-specified values use the default 
% object already created to specify the properties.                             
%                              
% E.g., to change nLocUpdate type:
% 
% StrlCov_params.nLocUpdate = 10;
% 
% See also: staliro_options
%
%
% (C) 2015, Adel Dokhanchi, Arizona State University

classdef StrlCov_parameters
    
    properties
        multiHAs;

        nLocUpdate;

        coverageAlgorithm;

        pathCoverage;
        
        locSearch;
        
        specificLoc;
         
        numOfParallel;
        
        numOfMultiHAs;
        
        chooseBestSample;
        
        locationEncoding;
        
        singleHALocNum;
        
        startUpTime;
		
		instumentModel;
        % added by rahul
        modelInitFile;
        
        exclusionlist;
    end
    
    methods        
        function obj = StrlCov_parameters(varargin)
            obj.multiHAs = 0;
            
            obj.nLocUpdate = 1;
            
            obj.coverageAlgorithm = 'brute_force';
            
            obj.pathCoverage = 0;
            
            obj.locSearch='random';

            obj.specificLoc=0;
             
            obj.numOfParallel=1;
            
            obj.numOfMultiHAs=[];
            
            obj.chooseBestSample=0;
            
            obj.locationEncoding = 'combinatorial';
            
            obj.singleHALocNum=0;
            
            obj.startUpTime=0;
			
			obj.instumentModel=0;
            
            %added by rahul
            obj.modelInitFile=''; % .mat fie required for compiling the model. Required by model instrumentation.
            
            obj.exclusionlist = {}; %cell array of blocks to be excluded by model instrumentation.

        end
    end
end

        