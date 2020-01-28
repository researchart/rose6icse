% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [h_sol, comptt, periter, end_opt] = RED(descentargv, nbellipsoids)
% Applies Algorithm 1 (RED) to solve successive Prob[Wi] to find a local min of 
% the robustness function, starting at input point h0. Iterations stop when
% optimum slack is 0 (i.e. equal to its initial value, implying
% convergence), or when a max nb of iterations is reached.
% 
% INPUTS
%     - descentargv  : input struct to the descent-finding algorithm. See find_local_min_rob_ell.m help for details. 
%     - nbellipsoids : max nb of iterations (each iteration solves one Prob[Wi] on a rob. ellipsoid). Default = 10.
%
% OUTPUTS
%     h_sol     : initial point (loc, time, state) with lowest robustness
%     comptt    : the iterations might increase the total simulation time.
%                 This is the final sim time (feature currently not supported).
%     periter   : struct containing per iteration information. Each
%                 field is an array with length = nb of iterations. Fields are
%       - rob     : robustness of solution in this iteration
%       - optiter : nb of _optimization_ iterations taken by optimizer in solving this
%                   problem Prob[Wi]
% 	 end_opt    : put an end to the entire optimization

% (C) Houssam Abbas, Arizona State University, 2013

global RUNSTATS;
Rcmap = rcmap.instance();

HA          = descentargv.HA;
if nargin < 2
    nbellipsoids = 10;
end
col = ['b','k','m','r', 'c', 'y'];

% Per iteration statistics
periter 			= struct('rob', inf(1,nbellipsoids), 'optiter', zeros(1,nbellipsoids));
% RUNSTATS.nb_function_evals_this_run is cumulative over everything happening 
% in this run of the code. 
% To keep track of the nbse for this call, we must first record the nbse  
% consumed so far, and that is base_nbse. At the end of each ellipsoid
% (iteration of the for loop), we subtract the nb_functions_evals_this_run
% from base_nbse.
base_nbse 			= RUNSTATS.nb_function_evals_this_run();
% In this call, we start with a maximum allowed nbse = max_nbse. This is
% basically what the user chose as max nbse (via descentargv) minus what
% was used up so far before this call. In other words,
% this is what's available for the remainder of the entire run.
max_nbse 			= max([descentargv.max_nbse 0]); % could be inf
% After each iteration ( = each ellipsoid), we reduce running_max_nbse.
running_max_nbse  	= max_nbse;  
% Some algos will impose a limit on nbse in a given descent.
nbse_per_descent = descentargv.nbse_per_descent;
running_nbse_per_descent = nbse_per_descent;
disp(['Nbse per descent = ',num2str(nbse_per_descent)])
end_opt  			= 0;
prev_rob 			= inf;

for it=1:nbellipsoids
%     profile on -nohistory
    display(['---------- Ellipsoid it = ',num2str(it), '---------------']);
    descentargv.it                  = it;
	descentargv.max_nbse            = running_max_nbse;    
    if descentargv.red_hard_limit_on_ellipsoid_nbse
        % Some ellipsoid optimization algos might require, or desire, a
        % hard limit on nbse expenditure in each ellipsoid. E.g. UR has no
        % natural stopping/convergence criterion, so it requires one. The
        % following is a suggestion.        
        descentargv.one_ellipsoid_max_nbse  = ceil(running_nbse_per_descent/(nbellipsoids-it));        
        disp(['Max nbse per ellipsoid minimization = ', num2str(descentargv.one_ellipsoid_max_nbse)]);
        if descentargv.one_ellipsoid_max_nbse <= 1
            % We need one nbse just to compute the nominal trajectory for
            % the robustness ellipsoid, so this run won't yield any
            % optimization. So we save this one nbse for an optimization
            % iteration later.
            falsify_outargv = struct('rc', Rcmap.int('RC_NO_OPTIMIZATION'), 'h_sol', descentargv.h0, 'tt', descentargv.tt, 'z_sol', [], 'nboptiter', 0, 'fval', nan);
            break;
        end
    end
    %--------------------------------------------------------------------------
    % Compute robustness ellipsoid for HA, centered at h0
    % Ellipsoid = {x | (x-center)*Pinv*(x-center) <= 1
    %--------------------------------------------------------------------------   
    couleur = col(1+mod(it, length(col)));
    if length(HA.loc) == 1 && isempty(HA.resets) % 1 location - dynamical system
        Pinv=[];
        ell_dist = inf;
        center = descentargv.h0(3:end);
    else
        disp('Computing robustness ellipsoids');
        minEllRad = descentargv.red_min_ellipsoid_radius; % min radius below which we judge there's no point searching 
        robust_opts ={0; [0 0]; [10^-3 5]; 1};
        [~, locHis, ell_dist, distHis, ~, ell, robust_test_news] = robust_test_ha(descentargv.h0,HA,descentargv.tt, HA.ode_solver, robust_opts);        
        if descentargv.plotit; plot(projection(ell, [1 0; 0 1; 0 0; 0 0]), couleur); end
    end
    
    %--------------------------------------------------------------------------
    % Descend in robustness ellipsoid if it is big enough
    %--------------------------------------------------------------------------   
    [center, P] = parameters(ell);
    Pinv = inv(P);
    if min(distHis) < minEllRad
        disp(['[RED] The robustness ellipsoid is smaller than ',num2str(minEllRad),' in some locations - no point doing search'])
        falsify_outargv = struct('rc', Rcmap.int('RC_NO_OPTIMIZATION'), 'h_sol', descentargv.h0, 'tt', descentargv.tt, 'z_sol', [], 'nboptiter', 0, 'fval', nan);
    elseif robust_test_news == Rcmap.int('RC_SIMULATION_UNSAFE_SET_REACHED')
        disp('[RED] While running robust_test_ha, we reached unsafe set at center of ellipsoid')
        falsify_outargv = struct('rc', Rcmap.int('RC_SUCCESS'), 'h_sol', descentargv.h0, 'tt', descentargv.tt, 'z_sol', [], 'nboptiter', 0, 'fval', 0);
    elseif nnz(isnan(Pinv)) > 0
        error('[RED] Pinv has NaN entries, even though it is supposed to be postive definite.')
    else
        if descentargv.plotit plot(projection(ell, [1 0; 0 1; 0 0; 0 0]), couleur); end        
        % Sanity check
        assert(nnz(center-descentargv.h0(3:end)')==0);        
        descentargv.locHis          = locHis;
        descentargv.ell_params{1}   = Pinv;
        descentargv.ell_params{2}   = center;
        descentargv.ell_params{3}   = ell_dist;
        descentargv.couleur         = couleur;
        disp(['[',mfilename,'] finding local min in rob_ell']);
        falsify_outargv = find_local_min_rob_ell(descentargv);
    end
    
    h_sol           = falsify_outargv.h_sol;
    comptt          = falsify_outargv.tt;
    nboptiter       = falsify_outargv.nboptiter;
    fval            = falsify_outargv.fval;
	rc              = falsify_outargv.rc;
    if rc ~= Rcmap.int('RC_SUCCESS')
        warning(['find_local_min_rob_ell returned rc = ', Rcmap.str(rc)]);    
    end

    % If solving the auxiliary problem Prob[Wi], then fval (value of the
    % problem at optimizer, F(z_opt)) and robustness at the optimizer
    % (\rho(x_opt)) are not the same. Here we compute the robustness.
    RUNSTATS.stop_collecting(); 
    [hs2, rc2] = systemsimulator(HA, h_sol(3:end), [], comptt, [], 0);
    RUNSTATS.resume_collecting();     
    [~, ~, r_sol, ~, ix_rob] = DistTrajToUnsafe([hs2.T hs2.STraj]', HA.unsafe);
    display(['rob_it =',num2str(r_sol)]);

    periter.rob(it)         = r_sol;
    periter.optiter(it)     = nboptiter;
    periter.ell_dist(it)    = ell_dist;

    % Conditions to stop iterating
    break_early                     = 0;
    rob_decrease                    = 0.0001;
    nbse_due_to_this_call_so_far    = RUNSTATS.nb_function_evals_this_run() - base_nbse;
	running_max_nbse                = max_nbse - nbse_due_to_this_call_so_far;
    running_nbse_per_descent        = nbse_per_descent - nbse_due_to_this_call_so_far;
	if r_sol == 0 
        if HA.unsafe.same_location_as_me([hs2.LT(ix_rob), hs2.STraj(ix_rob,:)]) % JACKPOT!
            disp(['$$ [RED] Robustness = 0 - Bingo! $$'])
            break_early = 1;
        else
            disp('$$ [RED] Trouble brewing - zero continuous distance achived in location different from loc_unsafe $$')
        end
	elseif rc == Rcmap.int('RC_NO_OPTIMIZATION')
        disp('$$ [RED] There was no optimization in this iteration, and next iteration would just be a repeat - break $$')
        break_early = 1;
    elseif abs((prev_rob-r_sol)/prev_rob) <= rob_decrease
        disp(['$$ [RED] Robustness decrease is less than ', num2str(100*rob_decrease), '%  - break $$'])
        break_early = 1;
    elseif fval >= falsify_outargv.fval0 & strcmp(falsify_outargv.objective, 'auxiliary')== 1
        disp('$$ [RED] obj value fval did not decrease in this ellipsoid - looks like we converged $$')        
        break_early = 1;        
	elseif rc2==Rcmap.int('RC_SIMULATION_ZENO')
		display('$$ [RED] Found h_sol is ZENO so next iteration will not benefit us - break $$');
		break_early = 1;
    elseif descentargv.red_hard_limit_on_ellipsoid_nbse && running_nbse_per_descent <= 0
        display(['$$ [RED] running_nbse_per_descent = ',num2str(running_nbse_per_descent) , '<= 0 - break $$']);
		end_opt = 1;
		break_early = 1;
	elseif running_max_nbse <= 0
		display(['$$ [RED] running_max_nbse = ',num2str(running_max_nbse) , '<= 0 - break $$']);
		end_opt = 1;
		break_early = 1;
    elseif rc == Rcmap.int('RC_UNHAPPY_OPTIMIZATION')
        disp('$$ [RED] Local optimization was unsuccessful, and next iteration would just be a repeat - break $$')
        break_early = 1;        
    end
    if break_early
        break
    end
    
    descentargv.h0 = h_sol;
	
end % for it=1:nbellipsoids

periter.rob     = periter.rob(1:it);
periter.optiter = periter.optiter(1:it);
h_sol           = falsify_outargv.h_sol;
comptt          = falsify_outargv.tt;
rc              = falsify_outargv.rc;
if rc ~= Rcmap.int('RC_SUCCESS')
    warning(['find_local_min_rob_ell returned rc = ', Rcmap.str(rc)]);
end

1;
