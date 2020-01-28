% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function outargv = apply_descent_to_sample(curSample, argv, opt)
% Adapter:
% Sets up structures for minimize_robustness and runs it, then
% collects results for output.
global RUNSTATS;
temp            = RUNSTATS.nb_function_evals_this_run();
Rcmap           = rcmap.instance();
descentargv     = argv.descentargv;
descentargv.h0  = [descentargv.HA.init.loc 0 curSample'];
if ~isfield(descentargv, 'nbse_per_descent')    
    descentargv.nbse_per_descent = descentargv.max_nbse;
end

switch argv.local_minimization_algo
    case 'RED'
        [h_sol, ~, periter, end_opt] = RED(descentargv, argv.red_nb_ellipsoids);
        disp(['Ellipsoids dist = ',num2str(periter.ell_dist)]);
        disp(['(average dist = ', num2str(mean(periter.ell_dist)),')']);

    case 'NM'
        HA          = descentargv.HA;        
        fval0       = descentargv.base_sample_rob;        
        modeltype   = determine_model_type(HA);
        robfun      = @(x) Compute_Robustness_Right(HA, modeltype, x);
        x0          = descentargv.h0(3:end);
        if iscolumn(x0); x0 = x0'; end
        lb          = HA.init.cube(:,1);
        ub          = HA.init.cube(:,2);
        optset      = optimset('MaxFunEvals', descentargv.nbse_per_descent);
        [solution, fval, exitflag, output] = NM_optimize(robfun, x0, lb, ub, [], [], [], [], [], 'loose', optset);
        switch exitflag
            case {1,0,-1}
                rc = Rcmap.int('RC_SUCCESS');
            case 2
                rc = Rcmap.int('RC_NO_OPTIMIZATION');
            case -2
                rc = Rcmap.int('RC_OPTIMIZATION_RAN_BUT_FAILED');
            case -3
                rc = Rcmap.int('RC_UNHAPPY_OPTIMIZATION');
        end
        h_sol               = [HA.init.loc, 0, solution];
        periter.rob         = fval;
        periter.optiter     = output.iterations;
        periter.ell_dist    = inf;
        end_opt             = 0;        
        
    otherwise
        error(['Unknown local descent algorithm ', argv.local_minimization_algo,'.'])
end

nboptiter   = sum(periter.optiter);
r_sol       = min(periter.rob);

if opt.dispinfo
    fprintf(['\nLocal descent used up ',num2str(RUNSTATS.nb_function_evals_this_run() - temp ),' trajectories.\n']);
    disp(['Post-descent rob = ',num2str(r_sol)])
end

outargv = struct('h_sol', h_sol, 'nboptiter', nboptiter, 'r_sol', r_sol, 'end_opt', end_opt);
