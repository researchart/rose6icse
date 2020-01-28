% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [hh, locHis, dist, distHis, MM, ell, news] = robust_test_ha(h0,HA,tot_time,solv,opt)
% Function ROBUST_TEST_HA
%    Compute robustness neighborhood in the set of initial conditions for 
%    a trajectory of a hybrid automaton.
%
% INTERFACE:
%   [hh,locHis,dist,distHis,MM,ell] = robust_test_ha(h0,HA,tt,solv,opt)
%
% INPUTS: 
%   h0 = [l0, t0, x0]; 
%       l0 - initial control location
%       t0 - initial time
%       x0 - initial continuous state
%   HA - Hybrid automaton structure
%   tt - total simulation time
%   solv - ode solver for the simulation
%          default solver : 'ode45'
%   opt  - Optional. Various options.
%          If not provided or [], default values are used.
%   opt{1} : 0 use inequalities for guards (default)
%            1 use strict inequalities (necessary in cases where
%              the simulation stops right on the guard and in the 
%              new location there exists another guard that gets
%              activated with the current continuous state of the
%              system - in these cases the error message 'One of
%              the guards is violated before the simulation
%              starts' will appear)
%   opt{2}(1) - 0 : 0 use quadprog (default)
%               1 : 1 use cvx (cvx and sedumi must be installed)
%   opt{2}(2) - 0 : take into account system dyanmics (default)
%               1 : do not take into account the system dynamics when
%                   computing distance from guards
%   opt{3}(1) - Tolerance to regard a value as zero (default value 10^-3)
%   opt{3}(2) - percentage of the total time to continue simulation after 
%               the guard is crossed, e.g. 5 (namely 5%) 
%   opt{4}    - If 1, ignore unsafe set in ellipsoid computations.
%
% OUTPUTS:
%   hh - the trajectory of the hybrid automaton
%   locHis - the location history that corresponds to hh without location
%            repetitions 
%   dist - the minimum distance computed in the initial conditions
%   distHis - the minimum distance computed for each location in the locHis
%   MM - the lyapunov function (approximate bisimulation function) in the
%        initial location
%   ell - the robustness neighborhood in the initial location
%
%
% G. Fainekos - GRASP Lab - Last update 2006.07.30

% global testOptions
% 
% testOptions.IgnoreDyn = 0;
% testOptions.QPSolv = 0;

if nargin<5 || isempty(opt)
    optr ={[0 0]; [10^-3 5]};
    strict_guards = 0;
    ignore_unsafe = 0;
else
    strict_guards = opt{1};
    optr{1} = opt{2};
    optr{2} = opt{3};
    ignore_unsafe = opt{4};
    
end

global staliro_opt;
staliro_opt.hasim_params(1) = strict_guards;

% First pass - simulate the hybrid automaton
% (we assume that h0 does not activate any guards)
[hh, rc] = systemsimulator(HA, h0(3:end), [], tot_time,[],0);
% [hh,locHis,us] = hasimulator(HA,h0,tot_time,solv,[strict_guards 0 0 0 0 0]);

if rc==1 && ~ignore_unsafe
    dist = 0;
    distHis = [];
    warning('The unsafe set is reachable!');
    pause
else
    % % set MPT absolute tolerance
    % mpt_options('abs_tol',1e-14);
    
    % Second pass - calculate distances
    oldschoolhs = [hh.LT hh.T hh.STraj];
    [dist,distHis,MM] = computeMinDist(HA, oldschoolhs, hh.locHis, optr, ignore_unsafe);
    try
        ell = ellipsoid(hh.STraj(1,:)',dist^2*inv(MM)); %#ok<MINV>
    catch err
        fprintf('The call to ellipsoid failed. See MATLAB message below. \n If MATLAB built-in ellipsoid got called, this might be caused by a missing Ellipsoidal Toolbox.\nYou can download it from http://code.google.com/p/ellipsoids/.\n');
        rethrow(err);
    end
end

if nargout == 7
    news = rc;
end

locHis = hh.locHis;

end


