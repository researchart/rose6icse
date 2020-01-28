% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function outargv = NM_find_local_min_rob_ell(argv)
% See interface find_local_min_rob_ell.m

Rcmap = rcmap.instance();

HA = argv.HA;
h0 = argv.h0;
tt = argv.tt;

Pinv        = argv.ell_params{1};
maxSamples  = argv.max_nbse;
fval0       = argv.base_sample_rob;
rc          = Rcmap.int('RC_SUCCESS');

modeltype   = determine_model_type(HA);
robfun      = @(x) Compute_Robustness_Right(HA, modeltype, x);
x0          = h0(3:end); 
if iscolumn(x0); x0 = x0'; end 
lb          = HA.init.cube(:,1);
ub          = HA.init.cube(:,2);
if argv.red_hard_limit_on_ellipsoid_nbse
    optset      = optimset('MaxFunEvals', argv.one_ellipsoid_max_nbse);
else
    optset      = optimset('MaxFunEvals', maxSamples);
end
nonlcon     = @(x) ellipsoid_constraints(x,x0,Pinv);
[solution, fval, exitflag, output] = NM_optimize(robfun, x0, lb, ub, [], [], [], [], nonlcon, 'loose', optset);
% From optimize's help:
% exitflag - (See also the help on FMINSEARCH) A flag that specifies the 
%         reason the algorithm terminated. FMINSEARCH uses only the values
%  
%             1    fminsearch converged to a solution x
%             0    Max. # of function evaluations or iterations exceeded
%            -1    Algorithm was terminated by the output function.
%  
%         Since optimize handles constrained problems, the following two
%         values were added:
%  
%             2    All elements in [lb] and [ub] were equal - nothing done
%            -2    Problem is infeasible after the optimization (Some or 
%                  any of the constraints are violated at the final 
%                  solution).
%            -3    INF or NAN encountered during the optimization. 
%            
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

outargv = struct('h_sol', [HA.init.loc, 0, solution], 'tt', tt, 'z_sol', [], 'nboptiter', output.iterations, 'fval', fval, 'rmin', min(fval,fval0), 'fval0', fval0, 'ell_dist', argv.ell_params{2}, 'rc', rc);



    function [cin, ceq] = ellipsoid_constraints(x,x0,Pinv)
        cin = (x-x0)*Pinv*(x-x0)' - 1;
        ceq = [];
    end

end




