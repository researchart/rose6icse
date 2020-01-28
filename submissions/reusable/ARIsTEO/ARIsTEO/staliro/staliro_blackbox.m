% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef staliro_blackbox
% Class definition for S-Taliro Blackbox models. This is a class for 
% defining models for which the user is responsible for simulating. 
% The user needs to provide a function pointer to a function that given 
% the model inputs, it returns the resulting trajectories for the system.
%
% Remark:
%   This option could be used for hardware-in-the-loop (HiL) or 
%	software-in-the-loop (SiL) testing.
%
% Initialization:
% 
% bbmdl = staliro_blackbox
%
% The above function call sets the following default values for the class
% properties (along with a description of other possible choices). Each 
% property is initialized to the default value.
%
% bbmdl.model_fcnptr = @Blackboxmodel;
%     Set the function pointer to a function that simulates the blackbox 
%     model file. A blackbox function should obey the following interface:
%
%   Interface:
%       [T X Y L CLG GRD] = Blackboxmodel(X0, EndTime, TimeStamps, InpSignals)
%
%   Inputs:
%          X0 - the initial conditions or constant parameters as a column 
%				vector.
%     EndTime - the end time for the simulation. It is assumed that the 
%               start time is zero.
%  TimeStamps - time stamps that correspond to the sampling instances for 
%               the input signals in TimeStamps. 
%		        (This is optional if no input signals are required)
%  InpSignals - the input signals. This is an array where each column
%            	corresponds to a different signal and each row to time 
%            	instance that corresponds to TimeStamps.   
%		     	(This is optional if no input signals are required)
%   Outputs:
%       T  - the timestamps of the output trajectories.
%       X  - the state trajectory as an array where each column corresponds 
%			 to a different state variable. 
%       Y  - the output trajectory as an array where each column  
%		     corresponds to a different output variable. 
%       L  - the location/mode trajectory as an array where each column 
% 			 corresponds to a different stateflow chart or finite state 
%			 machine (FSM) in the blackbox model.
%			 Remark:
%			 	This can be empty if no state machines are present in the model 
%			 	or if their behavior is not important. 
%     CLG -  the graph that corresponds to the finite state machines or 
%			 Stateflow charts in the model.  
%			 Remark:
%			 	This can be empty if no state machines are present in the model, 
%			 	if their behavior is not important, or if they can be statically
%				defined. If the state machines do not dynamically change 
%               structure based on the initial conditions or parameters of the 
%				model, then it is recommended that will be statically defined  
%				in the blackbox class (see below) as opposed in the blackbox 
%				simulator.
%            CLG should be a cell vector with the adjacency list of the graph. 
%		     If there are multiple FSM, then G should be cell vector where 
%			 each entry is a cell vector with the adjacency list for each 
% 			 FSM. In this case, the length of G should match the number of 
%			 columns of L.
%			 Example: 
%				We will set a graph with 2 FSM with 2 states each:
%			 	FSM = {[2],[1]}; % State 1 transitions to 2 and vice versa.
%				CLG{1} = FSM;
%				CLG{2} = FSM;
%			 Remark:
%			 	This is required when hybrid distance metrics are used.
%      GRD - the guards that enable the switch from one location to the 
%			 next. 
%			 Remark:
%			 	This can be empty if no state machines are present in the model, 
%			 	if their behavior is not important, or if they can be statically
%				defined. If the state machines do not dynamically change 
%               structure based on the initial conditions or parameters of the 
%				model, then it is recommended that will be statically defined  
%				in the blackbox class (see below) as opposed in the blackbox 
%				simulator.
%			 In case of a single FSM, GRD is a structure array with the 
%		     following entries:
%				GRD(i,j).A; GRD(i,j).b
%			 A transition from state i to state j is enabled if the current 
%			 state is x and GRD(i,j).A*x<=GRD(i,j).b.
%			 The guards can be defined over the space 'X' or the space 'Y'. In 
%			 this case, the staliro option "spec_space" should be set to 'X' or 
%			 'Y' respectively.
%			 If there are multiple FSM, then GRD should be a cell vector
%			 where each entry should be structure array as defined above.
%
% opt.CLG = CLG
%     CLG -  the graph that corresponds to the finite state machines or 
%			 Stateflow charts in the model. 
%			 The CLG should be defined here if they have static structure, 
%		     i.e., their structure and guards do not depend on initial 
%			 conditions or constant system parameters.
% 
%			 This should be empty is it is provided by "model_fcnptr".
%
% opt.Grd = GRD
%      GRD - the guards that enable the switch from one location to the 
%			 next. 
%			 The GRD should be defined here if the transition guards have a 
%            static structure, i.e., they do not depend on initial 
%			 conditions or constant system parameters. In particular, A*x<=b 
%  			 is considered a static structure, but A(p)*x<=b(p) where p is set 
%			 during model initialization is not a static structure.
%
%			 This should be empty is it is provided by "model_fcnptr".
%
% num_of_HAs = opt.find_numofHAs(clg)
%       num_of_HAs - this is the number of state machines in the system. It
%       provides backward compatibility to single HA representation. Use
%       this method to obtain the number of HAs based on the CLG provided.
%
% (C) 2016, Rahul Thekkalore, Arizona State University

    properties
        model_fcnptr = '';
        CLG = {};
        Grd = [];
    end 
    
    methods
        
        function obj = staliro_blackbox(varargin)
            if nargin==1 && isa(varargin{1},'function_handle')
                obj.model_fcnptr = varargin{1};
            elseif nargin>1
                error(' staliro_blackbox: Please access directly the properties of the object.')
            end
        end
            
    end
    
    methods 
        function obj = set.model_fcnptr(obj,model_ptr)
           obj.model_fcnptr = model_ptr;
        end
        
        function obj = set.CLG(obj,Clg)
           obj.CLG=Clg;
        end
        function obj = set.Grd(obj,grd)
           obj.Grd=grd;
        end
    end
    
% to be added in next release. To be used by dp_taliro to check whether the
% system is single or multiple hybrid automatas.
%     methods
%         function num_of_HAs = find_numofHAs(clg)
%             if isnumeric(clg{1})
%                 if isempty(clg{1})
%                     num_of_HAs = 0;
%                 else
%                     num_of_HAs = 1;
%                 end
%             elseif iscell(clg{1})
%                 num_of_HAs = length(clg);
%             else
%                 error('Unknown representation of CLG \n ')
%             end
%         end
%     end
end

%check if guard exits for every clg..if not assert an error
% function check_clg_grd(obj)
%             % check if CLG is a non empty vector
%             if (~isempty(obj.CLG))&&~(isvector(obj.CLG))
%                 error('S-Taliro: Control graph must be a non empty vector.');
%             end
%             Clg_dim= length(obj.CLG);
%             % if grd not empty then check if grd is specified for every CLG 
%             % Grd empty implies no contraint on state transitions.
%             % So Grd must either be empty or exist for every CLG pair.
%             if ~isempty(obj.Grd) 
%                 for clg_col = 1 : Clg_dim
%             % CLG cell content must be vector with transition pair.
%                     if ~isvector(obj.CLG{clg_col})
%                         error('S-Taliro: Control graph cell must be a vector specifying transition from initial to finale state');
%                     end
%                     if (length(obj.CLG{clg_col})>2)
%                         error('S-Taliro: Control graph cell must be a vector specifying transition from initial to finale state')
%                     end
%             %for transition mentioned in CLG check if Grd is defined
%                     if (length(obj.CLG{clg_col}) == 2) 
%                         initial_loc = obj.CLG{clg_col}(1);                    
%                         final_loc = obj.CLG{clg_col}(2);
%                         if(isempty(obj.Grd(initial_loc,final_loc).A)||isempty(obj.Grd(initial_loc,final_loc).b))
%                             error('S-Taliro:Transition is specified between the two locations in control graph but guards for the transition not specified');
%                         end
%                     end
%                 end
%             end
%         end
