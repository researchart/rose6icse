% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [cin, ceq] = presimulated_traj_feasability_constr(x, argv)
% x : point where constraint is evaluated

global prev_z_iterate;
global prev_traj;

ha = argv.HA;
tt = argv.tt;
B = argv.descent_set;
h0 = argv.h0;
l0 = h0(1);
t0 = h0(2);
n = length(h0(3:end));
w0 = h0(3:end)';
Pinv = argv.Pinv;
use_slack_in_ge = argv.use_slack_in_ge;

x0 = x(1:n); % initial continuous state of system, in X0
% [tau1,..,tauN, t* = tau_{N+1}]
% note the index shift: tau(1) is when we enter loc(2), tau(i) is when we
% enter loc i+1.
tau = x(n+1:end-1);
t = tau;
v = x(end); % slack variable
% Nb of time instants where we enforce constaints in the optimization.
N = length(t);

h0 = [l0 t0 x0'];
x0prev = prev_z_iterate(1:n);
if isequal(x0, x0prev)
    hs = prev_traj;
else
    [ht, news]      = systemsimulator(ha, h0(3:end), [], tt, [], 0);
    hs              = [ht.LT ht.T ht.STraj];
%     [hs, dummy, news] = hasimulator(h0, ha, tt);    
    prev_z_iterate  = [x0; t; v];
    prev_traj       = hs;
end

% weights=ones(1,max(N, ix_descent_set-1));
% weights(ix_descent_set -1)=10;

cin=[]; % result of evaluating the constraints
% Constraint 7b: x0 \in Ellipsoid of robustness centered on w0
% <=> (x0-w0)*Pinv*(x0-w0) <= 1
G_E = (x0-w0)'*Pinv*(x0-w0)-1;
if use_slack_in_ge
    cin = [cin; G_E-v ];
else
    cin = [cin; G_E ];
end

% Constraint 7c: s_x(t) \in W
h_xt = get_hx_at_t(hs,t);
s_xt = h_xt(1,3:end);
G_W = B.pseudo_indicator(s_xt') - v;
cin = [cin; G_W];

ceq=[];

%====================================================
% Embedded functions
%====================================================
function h_xt = get_hx_at_t(hs,t)
% return value h = (loc, time, x) of input traj hs at input time t
ii = find(hs(:,2) == t);
if ii
    h_xt = hs(ii,:);
else
    % interpolate
    % hs = nb_of_poitns x [location, time, state]
    s_xt = interp1(hs(:,2), hs(:, 3:end), t);
    [l,entry_times, dummy,dummy] = entry(hs);
    I = find(entry_times <= t);
    if ~isempty(I)
        loc = l(I(end));
    else % all entry_times are greater than t => t happens in loc(1)
        loc = hs(1,1);
    end
    h_xt = [loc, t, s_xt];
end
