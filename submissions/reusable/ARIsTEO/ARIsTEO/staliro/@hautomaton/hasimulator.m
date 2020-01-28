% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Function [ht,lh,us] = HASIMULATOR(HA,h0,tt,solver,options)
%    Hybrid Automaton Simulator using Matlab ODE integrators
%
% Description: Simulate a hybrid automaton where each location i has the 
% following continuous time autonomous dynamics:
%       nonlinear:  dx/dt = f_i(t,x,u)                                 (1)
%       linear:     dx/dt = A_i*x+b_i_C_i*u                            (2)
%
% INPUTS:
%
%   - HA : Hybrid Automaton object, see class hautomaton
%
%   - h0 = [l0,t0,x0]; Initial state of the hybrid automaton
%       l0 - initial location
%       t0 - initial time
%       x0 - initial continuous state
%
%   - tt : Total simulation time. Note that the simulation terminates also
%          in the case that the system trajectory reaches the unsafe or 
%          the target sets. 
%
%   - solver : The name of the matlab ode solver, for example ode45, 
%       ode 23, or a user defined function with the same interface as the 
%       matlab ode solvers (to be modified later, use options for that).
%
%   - options : a vector of options
%       options(1) : 0 use inequalities for guards (default)
%                    1 use strict inequalities (necessary in cases where
%                      the simulation stops right on the guard and in the 
%                      new location there exists another guard that gets
%                      activated with the current continuous state of the
%                      system - in these cases the error message 'One of
%                      the guards is violated before the simulation
%                      starts' will appear)
%       options(2) : maximum stepsize for the solver
%       options(3) : Relative tolerance for the solver
%       options(4) : Absolute tolerance for the solver
%       options(5) : 0 (Default) error out if zeno 
%                    1 warn if zeno
%					 Note: The zeno detection is not guaranteed to work with 
%						   all models. The hasimulator is just a rudimentary 
%						   hybrid automaton simulator without any formal 
%						   guarantees. If you are looking for guaranteed 
%						   simulation results you are advised to look into 
%						   tools like the "Hybrid Equations Toolbox":
%					 http://www.mathworks.com/matlabcentral/fileexchange/41372-hybrid-equations-toolbox-v2-03
%
% OUTPUTS:
%
%   - ht : The hybrid automaton trajectory
%       ht = number of points * [location, time, continuous state]
%
%   - lh : The location history
%
%   - us : 1 the simulation has reached the unsafe set
%          0 the simulation has terminated without errors
%         -1 the simulation has reached the target set
%         -2 this is a Zeno trajectory
%         -3 simulation error - output is junk
%
% EXAMPLES:
%
% NAVIGATION BENCHMARK:
%   Load the hybrid automaton in the benchmark1 file:
%   >> HA = navbench_hautomaton(1); % just type HA = navbench_hautomaton; if you do not have MPT installed.
%   Then run the simulation with:
%   >> [ht,lt,us] = hasimulator(HA,[6 0 2.5 1.5 -1 0],5,'ode45');
%   Plot the results:
%   >> plot(ht(:,3),ht(:,4),'o')
%
% BOUNCING BALL:
%   >> BB = hautomaton('BounceBallDemo');
%   >> ha_dat = HA_Input_Data([1 0 5 0],[]);
%   >> [ht,lt,us] = hasimulator(BB,ha_dat,4,'ode45');
%   >> plot(ht(:,2),ht(:,3),ht(:,2),ht(:,4))
%
% TWO CLOCKS, ONE WITH DRIFT:
%   >> TC = hautomaton('TwoClockWithDrift');
%   >> t = 0:0.1:4;
%   >> u = -0.1*(1+sin(t));
%   >> ha_dat = HA_Input_Data([1 0 0 0],[t', u']);
%   >> [ht,lt,us] = hasimulator(TC,ha_dat,4,'ode45',[0 0.01 0 0 0]);
%   >> plot(ht(:,2),ht(:,3),ht(:,2),ht(:,4))
%
% See also: hautomaton, HA_Input_Data

% (C) Georgios Fainekos, 2009, Arizona State University

% (Important) History:
% 2016.05.24 GF: Added rudimentary support for reset functions
% 2011.10.03 GF: Changed it into a method
% 2009.10.15 GF: Added the option to not define 'unsafe' and 'target' sets
% 2009.03.17 GF: Added support for maximum stepsize, relative tolerance etc
% 2006.10.10 GF: First release

function [hh, locHis, unsafe] = hasimulator(HA,ha_dat,tot_time,solv,opt)

if nargin<5
    opt(1) = 0;
    opt(2) = 0;
    opt(3) = 0;
    opt(4) = 0;
    opt(5) = 0;
end
if length(opt) < 5
    ln = length(opt);
    opt(ln+1:5) = 0;
end
% Set options
options = odeset;
if opt(2)
    options = odeset(options,'MaxStep',opt(2));
end
if opt(3)
    options = odeset(options,'RelTol',opt(3));
end
if opt(4)
    options = odeset(options,'AbsTol',opt(4));
end
if opt(5)
    truncate_if_zeno = opt(5);
else
    truncate_if_zeno = 0;
end

% check for the unsafe set
unsafe = 0;

% number of locations
nloc = length(HA.loc); 

% Initial conditions
if isnumeric(ha_dat)
    h0 = ha_dat;
    inp_sig = [];
else
    h0 = ha_dat.h0;
    inp_sig = ha_dat.u;
end

% First pass - simulate the hybrid automaton
% (we assume that h0 does not activate any guards)
cloc = h0(1); % current location 
locHis = cloc; % location history
hh = h0; % hybrid system trajectory
% Check if the point is in the unsafe set
if ~isempty(HA.unsafe) && isPointInSet(h0(end,3:end)',HA.unsafe.A,HA.unsafe.b,'<')
    warning('hasimulator: The initial condition is in the unsafe set.')
    unsafe = 1;
    return;
end
while hh(end,2)<tot_time
    % Create the events
    actGuards = HA.adjList{cloc};
    % Set options
    if opt(1)
        options = odeset(options,'Events',@eventsStr);
        if sum(eventsStr(0,hh(end,3:end)')<0)>0  
            msg = ['At simulation step ',num2str(length(hh(:,1))),' one of the guards is violated before the simulation starts'];
            if truncate_if_zeno
                display(msg);
                unsafe = -2;
                return;
            else
                unsafe = -3;
                error(msg);
            end
        end 
    else
        options = odeset(options,'Events',@events);
        if sum(events(0,hh(end,3:end)')<0)>0  
            msg = ['At simulation step ',num2str(length(hh(:,1))),' one of the guards is violated before the simulation starts'];
            if truncate_if_zeno
                display(msg);
                unsafe = -2;
                return;
            else
                unsafe = -3;
                error(msg);
            end
        end 
    end
    % simulate system
    % dum1 - last time, dum2 - last state (for debugging)
    [tt,xx,dum1,dum2,guard] = feval(solv,@locDyn,[hh(end,2),tot_time],hh(end,3:end),options); %#ok<ASGLU>
    loc = ones(length(tt),1)*cloc; 
    % If guard is empty it should happen in the last iteration - add check
    if ~isempty(guard)
        ii = find(guard==noag+1, 1);
        if ~isempty(ii)
            % This is the case when we have reached the unsafe set
            hh = vertcat(hh,horzcat(loc(2:end),tt(2:end),xx(2:end,:))); %#ok<AGROW>
            unsafe = 1;
            return;
        end
        ii = find(guard==noag+2, 1);
        if ~isempty(ii)
            % This is the case when we have reached the target set
            hh = vertcat(hh,horzcat(loc(2:end),tt(2:end),xx(2:end,:))); %#ok<AGROW>
            unsafe = -1;
            return;
        end
        if length(guard)>1  
            warning(['The hybrid automaton is nondeterministic! While in location ',num2str(cloc),' the guards for locations ',num2str(actGuards(guard)),' are active!']); %#ok<WNTAG>
            guard = guard(1); %Choose a guard - in the future make the choice random
        end
        cloc = actGuards(guard);
        locHis = [locHis cloc]; %#ok<AGROW>
        loc(end) = cloc;
        % Apply the reset function (if defined) on the state that activated 
        % the guard; otherwise it is assumed that the reset function is the
        % identity map (no action taken)
        if (isfield(HA.guards(loc(end-1),loc(end)),'reset') && ~isempty(HA.guards(loc(end-1),loc(end)).reset))
            xx(end,:) = (HA.guards(loc(end-1),loc(end)).reset(xx(end,:)'))';
        end
    end
    % ignore first entry - same as last
    hh = vertcat(hh,horzcat(loc(2:end),tt(2:end),xx(2:end,:))); %#ok<AGROW>
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nested fuction definitions

% I Location Dynamics
function yy = locDyn(tt,xx) 
    if ~isempty(inp_sig)
        uu = (interp1(inp_sig(:,1),inp_sig(:,2:end),tt))';
    else
        uu = [];
    end
    if HA.loc(cloc).dyn == 0
        if isempty(uu)
            yy = HA.loc(cloc).A*xx+HA.loc(cloc).b;
        else
            if isempty(HA.loc(cloc).C)
                error(' hasimulator: C array not defined in hybrid automaton location dynamics')
            end
            yy = HA.loc(cloc).A*xx+HA.loc(cloc).b+HA.loc(cloc).C*uu;
        end
    elseif HA.loc(cloc).dyn == 1
        yy = HA.loc(cloc).f(tt,xx,uu);
    else
        errmsg = ['In hybrid automaton location ',num2str(cloc),' the option in the field "dyn" for location dynamics is not properly defined. See help file of hautomaton class.'];
        error(errmsg);
    end
end

% II Event function with inequalities
% OUTPUTS:
%   val -> the value of the event 
%            1 if the guard is not activated
%           -1 if the guard is activated
%   isterm -> does the computation stop?
%   dir -> what is the direction for crossing the zero value?
function [val,isterm,Dir] = events(tt,xx) %#ok<INUSL>
    noads = 2;
    % find active guards
    noag = length(actGuards);
    isterm = ones(noag+noads,1);
    Dir = zeros(noag+noads,1);
    val = zeros(noag+noads,1);
    for jj = 1:noag
        nloc = actGuards(jj);
        val(jj) = -isPointInSet(xx,HA.guards(cloc,nloc).A,HA.guards(cloc,nloc).b)+0.5;
    end
    % add an event for the unsafe set
    if ~isempty(HA.unsafe)
        val(noag+1) = -isPointInSet(xx,HA.unsafe.A,HA.unsafe.b)+0.5;
    end
    % add an event for the target sets
    if ~isempty(HA.target)
        val(noag+2) = -isPointInSet(xx,HA.target.A,HA.target.b)+0.5;
    end
end

% III Event function with strict inequalities
% OUTPUTS:
%   val -> the value of the event 
%            1 if the guard is not activated
%           -1 if the guard is activated
%   isterm -> does the computation stop?
%   dir -> what is the direction for crossing the zero value?
function [val,isterm,Dir] = eventsStr(tt,xx) %#ok<INUSL>
    noads = 2;
    % find active guards
    noag = length(actGuards);
    isterm = ones(noag+noads,1);
    Dir = zeros(noag+noads,1);
    val = zeros(noag+noads,1);
    for jj = 1:noag
        nloc = actGuards(jj);
        val(jj) = -isPointInSet(xx,HA.guards(cloc,nloc).A,HA.guards(cloc,nloc).b,'<')+0.5;
    end
    % add an event for the unsafe set
    if ~isempty(HA.unsafe)
        val(noag+1) = -isPointInSet(xx,HA.unsafe.A,HA.unsafe.b,'<')+0.5;
    end
    % add an event for the target sets
    if ~isempty(HA.target)
        val(noag+2) = -isPointInSet(xx,HA.target.A,HA.target.b,'<')+0.5;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
