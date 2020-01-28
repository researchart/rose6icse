% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function outargv = UR_find_local_min_rob_ell(argv)
% See interface find_local_min_rob_ell.m

global RUNSTATS;
Rcmap = rcmap.instance();

HA = argv.HA;
h0 = argv.h0;
tt = argv.tt;

Pinv = argv.ell_params{1};
center = argv.ell_params{2};
maxSamples = argv.one_ellipsoid_max_nbse;
rc = Rcmap.int('RC_SUCCESS');

space = struct('shape', 'ellipsoid_inter_rectangle', 'Pinv', Pinv, 'center', center, 'rectangle', argv.HA.init.cube, 'ellipsoid_volume', (4*pi/3)*sqrt(det(Pinv)));
[x, sample_success] = get_next_ur_sample(space);
nb_samples = 1;
rmin = argv.base_sample_rob;
bestH = h0;
while (sample_success && nb_samples <= maxSamples)
    h = [h0(1:2) x'];
    [hs, rc] = systemsimulator(HA, h(3:end), [], tt, [], 0);
    [~, ~, dmin] = DistTrajToUnsafe([hs.T hs.STraj]', HA.unsafe);
    if rc == Rcmap.int('RC_SUCCESS')
        if dmin < rmin
            bestH = h;
            rmin = dmin;
        end
    elseif rc == Rcmap.int('RC_SIMULATION_UNSAFE_SET_REACHED') || rc == Rcmap.int('RC_SIMULATION_TARGET_SET_REACHED')
        bestH = h;
        rmin = dmin;
        break;
    else
        warning(['[UR_local_min_rob_ell] rc = ', Rcmap.str(rc), ' is not good']);
    end
    [x, sample_success] = get_next_ur_sample(space);
    nb_samples = nb_samples+1;
end

if ~sample_success
    rc  = Rcmap.int('RC_UNHAPPY_OPTIMIZATION');
elseif isinf(rmin)
    rc = Rcmap.int('RC_OPTIMIZATION_RAN_BUT_FAILED');
end

RUNSTATS.stop_collecting();
type = determine_model_type(HA);
fval0 = Compute_Robustness_Right(HA, type, h0(3:end));
%fval0 = harobustness(HA, tt, h0);
RUNSTATS.resume_collecting();
outargv = struct('h_sol', bestH, 'tt', tt, 'z_sol', [], 'nboptiter', nb_samples, 'fval', rmin, 'rmin', rmin, 'fval0', fval0, 'ell_dist', argv.ell_params{2}, 'rc', rc);



