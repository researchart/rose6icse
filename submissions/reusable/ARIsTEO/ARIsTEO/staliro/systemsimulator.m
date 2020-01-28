% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% NAME
% 
%     systemsimulator
% 
% SYNOPSYS
%    
%     [hs, rc, sigData] = systemsimulator(inputModel, XPoint, UPoint, staliro_SimulationTime, staliro_InputBounds, nb_ControlPoints, staliro_opt_offline)
%     
% DESCRIPTION
% 
%     Simulate the input inputModel, starting at the provided initial conditions, and with the provided control input.
%     
%     INPUTS
%
%     inputModel
%         The system to be simulated. Can be a function handle, an object of class hautomaton, or a simulink .mdl model.
%         In the last case, inputModel is of data type string.
%         
%     XPoint
%         A vector of initial conditions appropriate for the inputModel. 
%        
%     UPoint
%         A vector of control points. E.g. if the input signal is to be a linear interpolation between 3 input values, 
%         UPoint contains the 3 values. If the system has more than one
%         input signal, then their control point values are concatenated in
%         UPoint: e.g. f inputSignal1 has 2 control points, and inputSignal2 has 3
%         control points, then UPoint will be a vector of the form
%         [cp1_1 cp1_2   cp2_1 cp2_2 cp2_3]
%         ------------   -----------------
%         Cntrl Pnts      Cntrl Pnts for 
%         for inpSig1     inpSig2
%     
%     staliro_SimulationTime
%         Duration of simulated trajectory.
%         
%     staliro_InputBounds
%         A 2-dimensional vector giving lower and upper bounds on input values.
%         
%     nb_ControlPoints
%         Length of UPoint = number of knots at which the input signal interpolation happens.
%         NOTE: if an staliro_options object is passed as argument (see
%         below), then nb_ControlPoints will be assumed to be in the input
%         array for control points as provided to staliro. See staliro help
%         file.
%
%     staliro_opt_offline
%         In case the system simulator is called outside staliro, an options object should be provided. 
%         If one is not provided, a default object will be created.
%         NOTE: The staliro_options is not passed as argument from staliro;
%         only when systemsimulator is called outside staliro.
%
%     OUTPUTS
%
%     hs
%         Output trajectory is a struct with keys: 
%               T      = col' vector of time stamps of simulated trajectory, 
%               XT     = internal states at the time stamps, 
%               YT     = outputs at the time stamps, 
%               LT     = locations at the time stamps
%               locHis = sequence of visited locations
%               STraj  = XT or YT depending on staliro_options.spec_space, 
%               GRD    = guard structure, 
%               CLG = Control Location Graph.
%         Some of these will be empty, depending on the type of system being simulated. E.g. if it's a simulink model, 
%         at least CLG, LT and GRD will be empty.
%      
%     rc 
%         Return code. Because systemsimulator might call system-defined simulators, the values vary, but always obey the
%         rule that 0 means 'everything is OK', and a negative value means 'something went wrong'. Positive values mean
%         different good or neutral things.  In particular, -3 means simulation errored, output is junk.
%
%     sigData
%         Return the input signals to the model. This is an array where the
%         first column contains the timestamps and the rest of the columns
%         the input signals. This is not used in staliro and it is provided
%         as an option for stand alone calls.
%     
%     IMPORTANT NOTE: if a system specifies its own simulator, that simulator must conform to the interface of systemsimulator.
% 

%     (C) 2013, Houssam Abbas, Arizona State University
%     Based upon (now obsolete) Compute_Robustness_Sub.m

function [hs, rc, sigData] = systemsimulator(inputModel, XPoint, UPoint, staliro_SimulationTime, staliro_InputBounds, nb_ControlPoints, staliro_opt_offline)

global staliro_opt;

global sysSimCounter;
sysSimCounter = sysSimCounter + 1;

if nargin==7
    staliro_opt = staliro_opt_offline;
    for ii = 2:length(nb_ControlPoints)
        nb_ControlPoints(ii) = nb_ControlPoints(ii)+nb_ControlPoints(ii-1);
    end
end
if ~isa(staliro_opt, 'staliro_options')
    % if running this outside staliro, staliro_opt won't be initialized (or
    % of the wrong type)
    staliro_opt = staliro_options;
    if length(UPoint)==1
        staliro_opt.interpolationtype = {'const'};
    end
end

global RUNSTATS;
if ~isa(RUNSTATS, 'RunStats')
    % If running this outside staliro, RUNSTATS won't be initialized (or of
    % the wrong type). We assume a serial run.
    RUNSTATS = RunStats(0);
    RUNSTATS.new_run();
end
myrcmap = rcmap.instance();


if isempty(nb_ControlPoints) == 0 % for the case where no input signal is used
    if (staliro_opt.varying_cp_times == 1) && (length(UPoint) ~= nb_ControlPoints(end) + nb_ControlPoints(1))
        msg = sprintf('UPoint dimension does not match the values in nb_ControlPoints.\n See Help for how to set these 2 variables.');
        error(msg); %#ok<SPERR>
    elseif (staliro_opt.varying_cp_times == 0) && (length(UPoint) ~= nb_ControlPoints(end))
        msg = sprintf('UPoint dimension does not match the values in nb_ControlPoints.\n See Help for how to set these 2 variables.');
        error(msg); %#ok<SPERR>
    end 
end

inputModelType = determine_model_type(inputModel);

T = []; XT = []; YT = []; LT = []; CLG = []; GRD = []; locHis = []; STraj = []; %#ok<NASGU>
rc = 0;

if size(XPoint,2)>1
    XPoint = XPoint';
end
if staliro_opt.X0Fixed.fixed
    Xpoint_tmp = zeros(length(staliro_opt.X0Fixed.idx_search)+length(staliro_opt.X0Fixed.idx_fixed),1);
    Xpoint_tmp(staliro_opt.X0Fixed.idx_search) = XPoint;
    Xpoint_tmp(staliro_opt.X0Fixed.idx_fixed) = staliro_opt.X0Fixed.values;
    XPoint = Xpoint_tmp;
end
staliro_dimX = size(XPoint,1);

%% Compute input signals - if any 
if isempty(UPoint)
    % No input signals to the model
    steptime = [];
    InpSignal = [];
else
    steptime = (0:staliro_opt.SampTime:staliro_SimulationTime)';
    InpSignal = ComputeInputSignals(steptime, UPoint, staliro_opt.interpolationtype, nb_ControlPoints, staliro_InputBounds, staliro_SimulationTime, staliro_opt.varying_cp_times);
    % if inpSignal is empty then that means that the interpolation
    % function calculated a value outside of the predefined bounds
    if isempty(InpSignal)
        if staliro_opt.dispinfo == 1
            warning('S-Taliro issue:');
            txtmsg =          'An input signal does not satisfy the input constraints and          ';
            txtmsg = [txtmsg; 'the optimization function is not checking for this. You may want to '];
            txtmsg = [txtmsg; 'use a different interpolating function.                             '];
            disp(txtmsg)
        end
        rc = myrcmap.int('RC_SIMULATION_FAILED');
    end
end
sigData = [steptime InpSignal];

%% Simulate model
%%%%%%%%% section edited by Rahul %%%%%%%%%%%%%%
% now function handle and blackbox model case are separated
% if using blackbox option already model is typecasted to blackbox class
% No need to check for opt.blackbox option
if strcmp(inputModelType, 'Block_Diagram_Model')

    opt = simOptions('InitialCondition', XPoint);
     
    d=iddata([],InpSignal,staliro_opt.SampTime);
    YT =sim(inputModel.model,d,opt);
    %YT.y=YT.y+Tr.OutputOffset;
    YT=YT.y;
 %   global f;
%    figure(f);
%    YT=YT(size(YT,1)/5:1:size(YT,1),:);
%    plot(InpSignal(:,1));
%    simtime=toc(tmc1);
    %disp(['simulation time: ',num2str(simtime)])
            
    %,'simulationTime', [0 10], 'solverOptions.stepSize', 1/1024);%, 'SaveState','on','StateSaveName','xout','SaveOutput','on','OutputSaveName','yout');
   % [T, XT]=simOut.get('xout').Values;     
    %YT=simOut.get('yout').Values;
elseif strcmp(inputModelType, 'function_handle')
        if strcmp(staliro_opt.ode_solver, 'default')
            ode_solver = 'ode45';
        else
            ode_solver = staliro_opt.ode_solver;
        end
        % Choose ODE solver and simulate the system        
        [T, XT] = SimFcnPtr(ode_solver, inputModel, staliro_SimulationTime, XPoint, UPoint, staliro_InputBounds, nb_ControlPoints, staliro_opt.interpolationtype, staliro_opt.varying_cp_times);        
        YT = XT; % Since there is no output signal explicitly defined

%%%%%%%%% section added by Rahul %%%%%%%%%%%%%%
% simulate the blackbox model and check for errors between clg and grd
elseif strcmp(inputModelType, 'blackbox_model')
        
         if ~isa(inputModel.model_fcnptr,'function_handle')
             error('S-Taliro: the balckbox model must be a function pointer')
         end
           
         [T, XT, YT, LT,CLG,GRD] = inputModel.model_fcnptr(XPoint, staliro_SimulationTime, steptime, InpSignal);
         if (isempty(CLG) && isempty(GRD))
             CLG = inputModel.CLG ;
             GRD = inputModel.Grd ;
         else
             if ~( isempty(inputModel.CLG) && isempty(inputModel.Grd))
                 if ~(isequal(CLG,inputModel.CLG)&& isequal(GRD,inputModel.Grd))
                     error('S-Taliro: Mismatch between staliro_blackbox and blackbox model in setting CLG/Grd. Please use either staliro_blackbox or blackbox model to set CLG and Grd')
                 end 
% TODO: GF: Check conditions above (is this tested?)
%              else
%                  inputModel.CLG = CLG ;
%                  inputModel.Grd = GRD;
             end
         end
         %inputModel.check_clg_grd();  % checks error btw CLG and guards specifications
         
%%%%%%%%%%%%%%%%%%%% end of section - Rahul %%%%%%%%%%%%%
    
elseif strcmp(inputModelType, 'hautomaton')  
    
    % If you're advertising yourself as a hautomaton, then your h0 will contain the initial location and simulation time.
    % If multiple initial locations, then find the first that does not satisfy any switching conditions.
    % We always assume non-deterministic hybrid automata with ASAP transitions.
    % At this point, it is assumed that x0 is inside the invariant of at least one location. The simulator has its own error checking.
    if isempty(XPoint)
        if ~isfield(inputModel.init,'h0') || isempty(inputModel.init.h0)
            error(' systemsimulator: if a search space for the initial conditions is not provided to staliro, then the initial conditions must be specified in the field init.h0 of the hautomaton.')
        end
        if size(inputModel.init.h0,1)==1
            XPoint = inputModel.init.h0';
        else
            XPoint = inputModel.init.h0;
        end
    end
    if length(inputModel.init.loc)>1
        for cloc = 1:length(inputModel.init.loc)
            l0 = cloc;
            actGuards = inputModel.adjList{cloc};
            noag = length(actGuards);
            for jLoc = 1:noag
                notbreak = 0;
                nloc = actGuards(jLoc);
                if staliro_opt.hasim_params(1) == 1
                    if isPointInSet(XPoint,inputModel.guards(cloc,nloc).A,inputModel.guards(cloc,nloc).b,'<')
                        notbreak = 1;
                        break
                    end
                else
                    if isPointInSet(XPoint,inputModel.guards(cloc,nloc).A,inputModel.guards(cloc,nloc).b)
                        notbreak = 1;
                        break
                    end
                end
            end
            if ~notbreak
                break
            end
        end
    else
        l0 = inputModel.init.loc(1);
    end
    if isempty(UPoint)
        h0 = [l0 0 XPoint'];
    else
        h0.h0 = [l0 0 XPoint'];
        h0.u = sigData;
    end
    if isfield(inputModel, 'simulator')
        mysimulator = inputModel.simulator;
        % A custom simulator's interface is assumed the same as the interface of systemsimulator
        [ht, ~, rc] = mysimulator(inputModel, h0, UPoint, staliro_SimulationTime, staliro_InputBounds, nb_ControlPoints);
    else
        if strcmp(staliro_opt.ode_solver, 'default')
            ode_solver = 'ode45';
        else
            ode_solver = staliro_opt.ode_solver;
        end
        [ht, ~, rc] = hasimulator(inputModel, h0, staliro_SimulationTime, ode_solver, staliro_opt.hasim_params);
    end    
    T =  ht(:, 2); % get time
    XT = ht(:, 3:end); % get continuous state trajecotry
    LT = ht(:, 1); % get location trace
    YT = []; % no output signals (GF: change later to allow observations?)
    CLG = inputModel.adjList; % location graph
    GRD = inputModel.guards; % the transition guards

elseif strcmp(inputModelType, 'ss') 
    
    [YT,T,XT] = lsim(inputModel,sigData(:,2:end),sigData(:,1),XPoint);
    
elseif strcmp(inputModelType, 'simulink')
    
    simopt = simget(inputModel);
    
    if staliro_dimX~=0
        simopt = simset(simopt, 'InitialState', XPoint);
    end
    if ~strcmp(staliro_opt.ode_solver, 'default')
        simopt = simset(simopt, 'Solver', staliro_opt.ode_solver);
    end
    
    if staliro_opt.SimulinkSingleOutput

        load_system(inputModel)

        set_param(inputModel,'SaveTime','on','TimeSaveName','tout');
        if strcmp(staliro_opt.spec_space,'X')
            set_param(inputModel,'SaveState','on','StateSaveName','xout');
        else
            set_param(inputModel,'SaveOutput','on','OutputSaveName','yout');
        end

        SimOutObj = sim(inputModel, [0 staliro_SimulationTime], simopt, [steptime, InpSignal]);

        if isnumeric(SimOutObj)
            close_system(inputModel,0)
            msg = sprintf('STaLiRo : staliro was expecting a structure for the Simulink model outputs. Instead a numeric array is returned.\nSet the staliro option SimulinkSingleOutput to 0 or modify the Simulink model single object \noutput option at Simulation > Model Configuration > Data Import/Export.');
            error(msg); %#ok<SPERR>
        end

        T = get(SimOutObj,'tout');
        if strcmp(staliro_opt.spec_space,'X')
            XT = get(SimOutObj,'xout');
            YT = [];
        else
            XT = [];
            YT = get(SimOutObj,'yout');
        end

        close_system(inputModel,0)

    else

        try
            tmc1 = tic;
            [T, XT, YT] = sim(inputModel, [0 staliro_SimulationTime], simopt, [steptime, InpSignal]);
            simtime=toc(tmc1);
            %disp(['simulation time: ',num2str(simtime)]);
        catch ME
            if (strcmp(ME.identifier,'Simulink:Engine:ReturnWkspOutputNotSupported'))
                msg = sprintf('STaLiRo : Simulink model "%s" outputs to a single variable in the workspace. \nSet the staliro option SimulinkSingleOutput to 1 or modify the Simulink model single object \noutput option at Simulation > Model Configuration > Data Import/Export.',inputModel);
                causeException = MException('MATLAB:myCode:dimensions',msg);
                ME = addCause(ME,causeException);
            end
            rethrow(ME)
        end

    end

    if isstruct(XT)
        XT = double([XT.signals.values]);
    end

    if isstruct(YT)
        YT = double([YT.signals.values]);
    end

    % Get location trace
    if ischar(staliro_opt.loc_traj)
        if strcmp(staliro_opt.loc_traj, 'end')
            LT = YT(:, end);
            YT(:,end) = [];
        elseif ~strcmp(staliro_opt.loc_traj, 'none')
            error('S-Taliro: "loc_traj" option not supported');
        end
    else
        LT = YT(:, staliro_opt.loc_traj);
        YT(:, staliro_opt.loc_traj) = [];
    end
    
elseif strcmp(inputModelType, 'interconnection')
    
    [ht, ~, rc] = inputModel.simulator(inputModel, [], UPoint, staliro_SimulationTime, staliro_InputBounds, nb_ControlPoints);
    T =  ht(:, 2); % get time
    XT = ht(:, 3:end); % get continuous state trajecotry
    LT = []; % get location trace
    YT = ht(:, 3:end); % no output signals
    CLG = []; % location graph
    GRD = []; % the transition guards
    
else
    error(' S-Taliro : Simulation model not suported!')
end

% Compute location/mode history 
%if ~isempty(LT)
%    sLT = [LT(1); LT(1:end-1)];
%    locHis = [LT(1); LT(LT-sLT ~= 0)];
%else
%    locHis = [];
%end
% Compute location/mode history For multiple HAs
    if ~isempty(LT)
        [mLT,nLT]=size(LT);
        if nLT==1
            sLT = [LT(1); LT(1:end-1)];
            locHis = [LT(1); LT(LT-sLT ~= 0)];
            staliro_opt.StrlCov_params.singleHALocNum=length(CLG);
        else
            sLT = [LT(1,:); LT(1:end-1,:)];
            sub = LT-sLT;
            s=size(sub);
            locHis = LT(1,:);
            for i=1:s(1)
                find=0;
                for j=1:s(2)
                    if sub(i,j)~=0
                        find=1;
                    end
                end
                if find==1
                    locHis=[locHis;LT(i,:)];
                end
            end
        end
    else
        locHis = [];
    end


% STraj is the trajectory to which applies the specification. 
% Some functions still use the old-school hs array form, and these  need an
% output from the simulator which corresponds to the spec_space. This
% provides that.
if strcmp(staliro_opt.spec_space,'X')
    assert(~isempty(XT),'STaLiRo : The state space variable X of the model is empty!')
    STraj = XT;
elseif strcmp(staliro_opt.spec_space,'Y') 
    assert(~isempty(YT),'STaLiRo : The output variable Y of the model is empty!')
    STraj = YT;
else
    error('STaLiRo : This should not have happened! It seems spec_space is not defined.')
end

RUNSTATS.add_function_evals(1);

%hs = struct('T', T, 'XT', XT, 'YT', YT, 'LT', LT, 'CLG', {CLG}, 'GRD', GRD, 'locHis', locHis, 'STraj', STraj);
% Updated for Multiple HAs
hs = struct('T', T, 'XT', XT, 'YT', YT, 'LT', LT, 'CLG', {CLG}, 'GRD', {GRD}, 'locHis', locHis, 'STraj', STraj);

end
%% Auxiliary functions

% GF 2011.08.21:
%
% A Simulink model simulation with sim cannot be performed while there
% is a nested function in the calling function. It seems that there is a
% problem with the memory space of the nested function and the workspace
% where simulink stores some variables. Thus, the nested function needs to
% be within another function definition. The nested function is necessary
% in order to avoid problems with global variables and parallel execution.

function [T, XT] = SimFcnPtr(odesolver, fcn_ptr, simTime, Xpt, Upt, inpBound, tmpCP, IntType, CPType)

[T, XT] = feval(odesolver, @ourmodel_wrapper, [0 simTime], Xpt);

%% Nested functions
    function DX = ourmodel_wrapper(t, X)
        
        if isempty(Upt)
            
            DX = feval(fcn_ptr, t, X);
            
        else
            
            Uin = ComputeInputSignals(t, Upt, IntType, tmpCP, inpBound, simTime, CPType);
            if isempty(Uin)
                error('S-Taliro: the bounds of the input signals have been violated. The interpolation function does not respect the input signal bounds.')
            end
            DX = feval(fcn_ptr, t, X, Uin);
            
        end
    end
%% End of nested functions

end
