% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
%% TaLiRo Monitor
% Computing the robustness estimate of timed state sequences of invariants 
% expressed in Metric Temporal Logic. That is a monitor evaluates a given
% formula Phi at every point in time. The recommended use of monitoring
% block is checking invariants of reactive response requirements.
%
%% Compatibility
% Monitoring toolbox is compatible with Matlab version R2012a or later 
%
%% IMPORTANT NOTICE:
% Add a "Rate Transition" block before the input. Set the "Output port
% sample time options" parameter of "Rate Transition" to "Specify". Set the
% "Output port sample time" parameter of "Rate Transition" as the sample
% time of the TaLiRo_Monitor.
%
%% INPUTS
%  The TaLiRo monitor has a single input port for the input signal. If the
%  multi-dimensional input is required, then use a "Vector Concatenate" or
%  a "Bus Creator" or a "Mux" block from the Simulink library.
%  
%% S-Function Parameters 
%  S-Function Parameters must be in the following order:
%  SignalDimension, Phi, Preds
%  1) SignalDimension is the size of the input signal to the monitoring     
%     block, without prediction.
%
%  2) Phi is the name of the MTL formula in the Matlab Workspace.
%    Multiple monitors can evaluate Simulink signals with respect to
%    different formulas.
%
%  3) Preds is the name of the predicate map in the Matlab Workspace.
%    For multiple formulas and monitors, the same predicate map is required.
%
%% PARAMETERS ( Define in Matlab Workspace )
%
%
%  'Phi' and 'Preds' are default name of parameters that should be set 
%   in Matlab workspace before simulation:
%   Formula  - Metric Temporal Logic formula
%              Any name can be used instead of "Formula" like "spec","phi"
%              as long as it is the name of a string in Matlab workspace.
%
%    Syntax: 
%      Phi := p | (phi) | !phi | phi \/ phi | phi /\ phi |
%                 phi -> phi | phi <-> phi | 
%                 X phi | phi U_[a,b] phi | phi R_[a,b] phi | 
%                 <>_[a,b] phi | []_[a,b] phi
%                 P phi | phi S_[a,b} phi | phi T_[a,b} phi | 
%                 <.>_[a,b} phi | [.]_[a,b} phi
%        where:  
%            p     is a predicate. Its first character must be a lowercase 
%                  letter and it may contain numeric digits.
%                  Examples: 
%                         pred1, isGateOpen2  
%
%            !     is not 
%
%            \/    is 'or'
%
%            /\    is 'and'
%
%            ->    is 'implies'
%
%            <->   if 'if and only if'
%
%            [a,b} where a and b are non-negative integer values and
%                  } is ) when b is inf, and } is ] when b is an integer. 
%                  Values of a,b are lower/upper bounds not on simulation  
%                  time, but on the number of samples. The actual sample  
%                  time constraints can be derived from the sampling value  
%                  of the "Rate Transition" block.
%
%            X     is the 'next' operator. It is equivalent to <>_[1,1].
%
%            U_[a,b] is the 'until' operator with time bounds [a,b]. 
%
%            R_[a,b] is the 'release' operator with time bounds [a,b].
%
%            <>_[a,b] is the 'eventually' operator with time bounds [a,b].
%
%            []_[a,b] is the 'always' operator with time bounds [a,b].   
%
%            P    is the 'previous' operator. It is equivalent to <.>_[1,1].
%
%            S_[a,b} is the 'since' operator with time bounds [a,b}. 
%                  If no time bounds are required, then use S.
%
%            T_[a,b} is the 'trigger' operator (past time version of 
%                  'release') with time bounds [a,b}. If no time bounds are
%                  required, then use T.
%
%            <.>_[a,b} is the 'eventually in past' operator with time bounds [a,b}.
%                  If no timing constraints are required, then simply use <.>.
%
%            [.]_[a,b} is the 'always in past' operator with time bounds [a,b}.  
%                  If no timing constraints are required, then simply use [.].
%
%          Examples:
%             * Bounded Response:
%               Always between 3 to 5 samples in the past 'p1' implies 
%                      eventually 'p2' within 1 sample.
%                   phi_1 = '[.]_[3,5](p1 -> <>_[0,1] p2)';
%               
%             * Until:
%               'p1' is true until 'p2' becomes true after 4 and before 7  
%               samples
%                   phi_2 = 'p1 U_[4,7] p2';
%             * Eventually:
%               'p1' eventually will become true between 1 and 6 
%               samples 
%                   phi_3 = '<>_[1,6] p1';
%             * Release:
%              'p2' must always be true between 2 and 9 samples 
%               unless 'p1' becomes true before that
%                   phi_4 = 'p1 R_[2,9] p2';
%   Preds - The mapping of the predicates to their respective states.
%            Any name can be used instead of "Preds" like "predicate",
%            "predmap" as long as it is the name of the predicate map in 
%            Matlab workspace.
%
%          Preds(i).str : the predicate name as a string 
%          Preds(i).A, Preds(i).b : a constraint of the form Ax<=b
%              Setting A and b to [] implies no constraints. That is, the set
%              is R^n.
%
%          Examples:
%             * 'p1' indicates that x>=-2:
%                Preds(1).str = 'p1';
%                Preds(1).A = -1.0;
%                Preds(1).b = 2.0;
%             
%             * 'p2' indicates that x<=2:
%                Preds(2).str = 'p2';
%                Preds(2).A = 1.0;
%                Preds(2).b = 2.0;
%
%
%% OUTPUT
%
%
%  The robustness estimate at each simulation step for the invariant formula.
%
%% Model-Predictive Monitor
%  Besides monitoring with the current samples, the on-line monitor can
%  consider the future horizon (prediction).
%  The prediction horizon is the number of future samples that is predicted
%  for example by a predicting model. The prediction horizon must be less 
%  than or equal to the Phi's horizon: 
%  For computation of Phi's horizon refer RV 2014 paper:
%  Adel Dokhanchi, Bardh Hoxha, and Georgios Fainekos, 
%  On-Line Monitoring for Temporal Logic Robustness, 
%  Runtime Verification, Toronto, Canada, September 2014 
% 
%  RV 2014 paper is available in the following Link:
%  https://doi.org/10.1007/978-3-319-11164-3_19
%  The proof of the RV 2014 is available in the following Link: 
%  http://arxiv.org/abs/1408.0045
%
%  The input signal size must be the multiplication of the SignalDimention
%  parameter specified in the monitor block.
%  The prediction horizon is computed as follows: 
%
%  Prediction Horizon = ( Input Signal Size / SignalDimension ) - 1
%
%  For more information about Model-Predictive Monitor, email: 
%  fainekos@asu.edu 
