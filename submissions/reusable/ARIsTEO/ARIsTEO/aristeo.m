% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% function aristeo - Falsifies a Signal Temporal Logic (STL) formula
%
%
% USAGE
%
%         [results,input] = aristeo(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, aristeo_options)
%
% DESCRIPTION :
%
%   ARISTEO performs temporal logic falsification and parameter mining  
%   for hybrid systems models. The input model can be in several forms, 
%   such as a Simulink model or an m-function, and the specification  
%   can be a Signal Temporal Logic (STL) formula which is encoded using  
%   a Metric Temporal Logic (MTL) formula.
%
% INPUTS :
%
%   - model : can be of type:
%
%       * function handle : 
%         It represents a pointer to a function which will be numerically 
%         integrated using an ode solver (the default solver is ode45). 
%         The solver can be changed through the option
%                   staliro_options.ode_solver
%         See documentation: <a href="matlab: doc staliro_options.ode_solver">staliro_options.ode_solver</a>
%
%       * Blackbox class object : 
%         The user provides a function which returns the system behavior 
%         based on given inputs and initial conditions. For example, this 
%         option can be used when the system simulator is external to 
%         Matlab. Please refer tp the staliro_blackbox help file.
%         See documentation: <a href="matlab: doc staliro_blackbox">staliro_blackbox</a>
%
%       * string : 
%         It should be the name of the Simulink model to be simulated.
%
%       * hautomaton :
%         A hybrid automaton of the class hautomaton.
%         See documentation: <a href="matlab: doc hautomaton">hautomaton</a>
%
%       * ss or dss :
%         A (descriptor) state-space model (see help file of ss or dss).
%         If the ss or dss models are discrete time models, then the 
%         sampling time should match the sampling time for the input 
%         signals (see staliro_options.SampTime). If they are not the same,
%         then an error will be issued.
%         See documentation: <a href="matlab: doc ss">ss</a>, <a href="matlab: doc dss">dss</a>, <a href="matlab: doc staliro_options.SampTime">staliro_options.SampTime</a>
%
%       Examples: 
%
%           % Providing directly a function that depends on state and time
%           model = @(t,x) [x(1) - x(2) + 0.1*t; ...
%                   x(2) * cos(2*pi*x(2)) - x(1)*sin(2*pi*x(1)) + 0.1 * t];
%
%           % Just an empty Blackbox object
%           model = staliro_blackbox; 
%           
%           % For other blackbox examples see the demos in demos folder:
%           staliro_demo_sa_simpleODE_param.m
%           staliro_demo_autotrans_02.m
%           staliro_demo_autotrans_03.m
% 
%           % Simulink model under demos\SystemModelsAndData
%           model = 'SimpleODEwithInp'; 
%
%           % Hybrid automaton example (demo staliro_navbench_demo.m)
%           model = navbench_hautomaton(1,init,A);
%
%   - init_cond : a hyper-rectangle that holds the range of the initial 
%       conditions (or more generally, constant parameters) and it should be a 
%       Matlab n x 2 array, where 
%			n is the size of the vector of initial conditions.
%		In the case of a Simulink model or a Blackbox model:
%			The array can be empty indicating no search over initial conditions 
%			or constant parameters. For Simulink models in particular, an empty 
%			array for initial conditions implies that the initial conditions in
%			the Simulink model will be used. 
%
%       Format: [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_n UpperBound_n];
%
%       Examples: 
%        % A set of initial conditions for a 3D system
%        init_cond = [3 6; 7 8; 9 12]; 
%        % An empty set in case the initial conditions in the model should be 
%        % used
%        init_cond = [];
%
%       Additional constraints on the initial condition search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%
%   - input_range : 
%       The constraints for the parameterization of the input signal space.
%       The following options are supported:
%
%          * an empty array : no input signals.
%              % Example when no input signals are present
%              input_range = [];
%
%          * a hyper-rectangle that holds the range of possible values for 
%            the input signals. This is a Matlab m x 2 array, where m is the  
%            number of inputs to the model. Format:
%               [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_m UpperBound_m];
%            Examples: 
%              % Example for two input signals (for example for a Simulink model 
%              % with two input ports)
%              input_range = [5.6 7.8; 8 12]; 
%
%          * a cell vector. This is a more advanced option. Each input signal is 
%            parameterized using a number of parameters. Each parameter can 
%            range within a specific interval. The cell vector contains the
%            ranges of the parameters for each input signal. That is,
%                { [p_11_min p_11_max; ...; p_1n1_min p_1n1_max];
%                                    ...
%                  [p_m1_min p_m1_max; ...; p_1nm_min p_1nm_max]}
%            where m is the number of input signals and n1 ... nm is the number
%                  of parameters (control points) for each input signal.
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%       Additional constraints on the input signal search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%
%   - cp_array : contains the control points that parameterize each input 
%       signal. It should be a vector (1 x m array) and its length must be equal 
%       to the number of inputs to the system. Each element in the vector 
%       indicates how many control points each signal will have. 
%
%       Specific cases:
%
%       * If the signals generated using interpolation between the control  
%         points, e.g., piece-wise linear or splines (for more options see 
%         <a href="matlab: doc staliro_options.interpolationtype">staliro_options.interpolationtype</a>): 
%		  
%         Initially, the control points are equally distributed over 
%         the time duration of the simulation. The time coordinate of the 
%         control points will remain constant unless the option
%
%					<a href="matlab: doc staliro_options.varying_cp_times">staliro_options.varying_cp_times</a>
%
%         is set (see the staliro_options help file for further instructions and 
%         restrictions). The time coordinate of the first and last control 
%         points always remains fixed.
%
%         Example: 
%           cp_array = [1];
%               indicates 1 control point for only 1 input signal to the model.
%               One control point can only be used with piecewise constant 
%               signals. If we assume that the total simulation time is 6 time 
%               units and the input range is [0 2], then the input signal will 
%               be:
%                  for all time t in [0,6] u(t) = const with const in [0,2] 						
%
%           cp_array = [4];
%               indicates 4 control points for only 1 input signal to the model.
%               If we assume that the total simulation time is 6 time units, 
%               then the initial distribution of the control points will be:
%                            0   2   4   6
%
%           cp_array = [10 14];
%               indicates 10 control points for the 1st input signal and 
%               14 for the second input.
%
%      * If the input_range is a cell vector, then the input range for each
%        control point variable is explicitly set. Therefore, we can
%        extract the number of control points from the number of
%        constraints. In this case, the cp_array should be set to emptyset.
%
%           cp_array = [];
%
%   - phi : The formula to falsify. It should be a string. For the syntax of MTL 
%       formulas type "help dp_taliro" (or see staliro_options.taliro for other
%       supported options depending on the temporal logic robustness toolbox 
%       that you will be using).
%                               
%       Example: 
%           phi = '!<>_[3.5,4.0] b)'
%
%       Note: phi can be empty in case the model is a hybrid automaton 
%       object. In this case, an unsafe set must be provided in the hybrid
%       automaton.
%
%   - preds : contains the mapping of the atomic propositions in the formula to
%       predicates over the state space or the output space of the model. For 
%       help defining predicate mappings type "help dp_taliro" (or see 
%       staliro_options.taliro for other supported options depending on the 
%       temporal logic robustness toolbox that you will be using).
%
%       In case of parameter mining:
%           If staliro is run for specification parameter mining, then set the 
%           staliro option parameterEstimation to 1 (the default value is 0):
%               opt.parameterEstimation = 1;
%           and read the instructions under staliro_options.parameterEstimation 
%           on how to define the mapping of the atomic propositions.	
%
%   - TotSimTime : total simulation time.
%
%   - opt : aristeo_options options. opt should be of type "aristeo_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change Aristeo options, 
%       see the aristeo_options help file for each desired property.
%
% OUTPUTS
%   %   - results: a structure with the following fields
%
%       * run: a structure array that contains the results of each run of 
%           the stochastic optimization algorithm. The structure has the
%           following fields:
%               bestRob : The best (min or max) robustness value found
%               bestSample : The sample in the search space that generated 
%                   the trace with the best robustness value. 
%               nTests: number of tests performed (this is needed if 
%                   falsification rather than optimization is performed. See 
%					staliro_options.falsification for more information).
%               bestCost: Best cost value. bestCost and bestRob are the
%                   same for falsification problems. bestCost and bestRob
%                   are different for parameter estimation problems. The
%                   best robustness found is always stored in bestRob.
%               paramVal: Best parameter value. This is used only in 
%                   parameter mining or query problems. 
%					Important: This is valid if only if bestRob is negative.
%               falsified: Indicates whether a falsification occurred. This
%                   is used if a stochastic optimization algorithm does not
%                   return the minimum robustness value found.
%               time: The total running time of each run
%
%       * optRobIndex: stores the index of the run that contains the best 
%			(optimal) robustness value out of all runs.
%
%       * optParamValIndex: stores the index of the run that contains the 
%			optimal parameter value.
%
%		* polarity: indicates whether the specification has positive (increasing)
%         or negative (decreasing) robustness monotonicity with respect to
%         the parameters.
%
%       * RandState: it stores information about the state of the random
%         number generator when staliro starts. See staliro_options for
%         further details. Documentation: <a href="matlab: doc staliro_options.seed">staliro_options.seed</a>
%
%
%   - opt: when using structural coverage, we need to extract information
%     regarding the number of locations or modes of the hybrid model.
%     In the current version of staliro this iformation is stored in
%     the staliro_options object and may need to be used by the function 
%     calling staliro.
%           TODO: This will be problematic in concurrent execution.
%                 Fix in a later version.
%		
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


function [results,input] = aristeo(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, aristeo_options)
% contains the number of abstraction/refinement steps

    global absreftime;
    global simtime;
    global statistics;
    global aristeo_options_backup;            

    if (aristeo_options.n_refinement_rounds < 1)
        error('the number of refinement rounds n_refinement_rounds of the aristeo options should be grather than zero')
    end
    % Initialize output variables - Avoid growing variables in a loop
    results.run(aristeo_options.runs) = struct('bestRob',[],'nTests',[],'executiontime',[],'falsificationtime',[],'absreftime',[],'simtime',[]);
    %% Run tests 
    aristeo_options_backup = aristeo_options;


    for ii=1:aristeo_options.runs
        
            aristeo_options=aristeo_options_backup;
            executiontimetic = tic;
            results.run(ii).nTests = 10;
            results.run(ii).bestRob=9999;
            results.run(ii).time = 9999;        
            input=NaN;
            t=1;
             aristeo_options.X0Fixed.idx_search=[];
             aristeo_options.X0Fixed.idx_search=[];
             if(aristeo_options.dispinfo==1)
                disp(strcat('################################### Run: ',num2str(ii)));
             end

           data=[];
           X0=[];
           results.run(ii).falsificationtime=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).absreftime=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).simtime=zeros(1,aristeo_options.n_refinement_rounds);
           results.run(ii).executiontime=zeros(1,aristeo_options.n_refinement_rounds);
           

           done=false;
           while ((t<=aristeo_options.n_refinement_rounds) && ((aristeo_options.fals_at_zero==1 && results.run(ii).bestRob>0)||(aristeo_options.fals_at_zero==0 && results.run(ii).bestRob>=0)) )
               aristeo_options=aristeo_options_backup;
                iterationtimetic = tic;
               results.run(ii).simtime(t)=0;
                
                if(aristeo_options.dispinfo==1)
                        disp(strcat('RR ==> ',num2str(t)));
                end
                if (t==1 || ~done)
                    [data, abstractedmodel,X0, idOptions]=abstract(model,init_cond,input_range,cp_array,TotSimTime,aristeo_options);
                    done=true;
                    
                else
                    [data, abstractedmodel]=refine(data, model, abstractedmodel,aristeo_options, idOptions);
                end

                 absreftime
                results.run(ii).absreftime(t)=results.run(ii).absreftime(t)+absreftime;
                results.run(ii).simtime(t)=results.run(ii).simtime(t)+simtime;


                aristeo_options.X0Fixed.fixed=1;
                aristeo_options.X0Fixed.idx_fixed=1:1:size(X0,1);
                aristeo_options.X0Fixed.values=X0;
                aristeo_options.falsification=0;
                tmpinfo=aristeo_options.dispinfo;
                aristeo_options.dispinfo=0;
                falsificationtimetic=tic;
                aristeo_options=aristeo_options_backup;
               
                v=ver('Matlab'); 
                if(~isa(abstractedmodel,'idnlarx') && ~isa(abstractedmodel,'idnlhw') && ~isequal(v.Version,'7.11'))
                    if(isempty(abstractedmodel) || isnan(abstractedmodel) || ~isstable(abstractedmodel))
                        input=[];
                        done=false;
                    else
                        [input,~]=falsify(abstractedmodel,X0, input_range, cp_array, phi, preds, TotSimTime, aristeo_options);
                    end
                else    
                   [input,~]=falsify(abstractedmodel,X0, input_range, cp_array, phi, preds, TotSimTime, aristeo_options);
                end
                

                results.run(ii).falsificationtime(t)=toc(falsificationtimetic);
                aristeo_options.dispinfo=tmpinfo;

                [data, actualrob]=check(model,cp_array,input_range,init_cond,input,phi, preds,data, TotSimTime, aristeo_options);
                results.run(ii).simtime(t)=results.run(ii).simtime(t)+simtime;

                if(actualrob<results.run(ii).bestRob)
                    results.run(ii).bestInput=input;
                    results.run(ii).bestRob=actualrob;
                end

                statistics.iterationtime(1)=0;
                statistics.sim_t(1)=0;
                t=t+1;
                %bdclose('all');
                statistics.iterationtime(t)=toc(iterationtimetic);
                statistics.sim_t(t)=simtime;
            end
            results.run(ii).nTests = t-1;
            results.run(ii).executiontime = toc(executiontimetic);
            
    end
end
