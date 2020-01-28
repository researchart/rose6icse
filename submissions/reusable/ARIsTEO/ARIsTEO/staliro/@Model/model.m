% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  

function [hh, locHis, unsafe] = model(model)

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
