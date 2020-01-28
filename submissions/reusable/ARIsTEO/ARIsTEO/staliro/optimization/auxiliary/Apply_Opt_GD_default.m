% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [rob_saved, u_saved, n_sim] = Apply_Opt_GD_default(curSample, curVal, tmc, max_T, opt)
% This function applies a local optimal search to an initial input and returns
% the results. It is optionally used inside SA_Taliro. It can be used
% separately to apply optimal descent on a single random sample.
%
% Usage: 
%       [rob_saved, u_saved, n_sim] = Apply_Opt_GD_default(curSample, curVal, tmc, max_T, opt)
% Inputs:
%       curSample: Initial Sample to descend from
%       curVal: robustness of the initial sample
%       tmc: search starting time (tic)
%       max_T: maximum execution time
%       opt: staliro_options
% Outputs:
%       rob_saved: Final rob value
%       u_saved: Final sample
%       n_sim: number of iterations 
%
% See also: staliro, staliro_options, GD_parameters
%
% (C) 2019, Shakiba Yaghoubi, Arizona State University


global staliro_SimulationTime;
global staliro_InputModel;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_mtlFormula;
global staliro_Predicate;

SP.phi = staliro_mtlFormula;
SP.pred = staliro_Predicate;

TU = (0:opt.SampTime:staliro_SimulationTime)';
U = ComputeInputSignals(TU, curSample,opt.interpolationtype, temp_ControlPoints, staliro_InputBounds, staliro_SimulationTime, opt.varying_cp_times)';
U_saved = U;
rob_saved = curVal+eps;
n_sim = -1;
GD_params = opt.optim_params.GD_params;
h0 = GD_params.init_GD_step;
h = h0;
min_h = GD_params.min_GD_step;
model = GD_params.model;
k_red = GD_params.red_rate;
k_inc = GD_params.inc_rate;
linearized_timed_step = GD_params.linearized_timed_step;
io = getlinio(model);
while toc(tmc)<max_T-eps
    [T, XT, YT] = feval(staliro_InputModel.model_fcnptr,[],staliro_SimulationTime,TU,U); % change to include initial condition
%     [T, XT, YT] = sim(model,[0,staliro_SimulationTime]); %YT is the reference we want to follow
    [nearest_point_on_s, critical_t, rob,  ~, critical_point_on_pred] = staliro_critical_info(SP,XT,YT,T,opt); 
    n_sim = n_sim +1;
    if rob<rob_saved
        disp(['Current rob value = ',num2str(rob)])
        rob_saved = rob;
        U_saved = U;
    else
        while h>min_h && toc(tmc)<max_T-eps
            h = h/k_red;
            disp(['decreasing step size to ', num2str(h)])
            U = U_saved;
            U = arrayfun(@(x) min(staliro_InputBounds(2),max(x,staliro_InputBounds(1))),U+h*(staliro_InputBounds(2)-staliro_InputBounds(1))*du'/norm(du)); 
            simin.time = TU; simin.signals.values = U';
            [T, XT, YT] = sim(model,[0,staliro_SimulationTime]); %YT is the reference we want to follow
            [nearest_point_on_s, critical_t, rob, ~ , critical_point_on_pred] = staliro_critical_info(SP,XT,YT,T,opt);   
            n_sim = n_sim +1;
            if rob<rob_saved
                disp(['Current rob value = ',num2str(rob)])
                break
            end
        end
        if rob >= rob_saved 
            disp('Looks like local extrema')
            break
        else
           rob_saved = rob;
           U_saved = U;
        end
    end
    if rob<0 
        disp('Falsified')
        break
    end
    h = k_inc*h;
    TU_critical = TU(find(TU<=critical_t)); %#ok<FNDSB>
    linsys = linearize(model,io,0:linearized_timed_step:critical_t);
    assert(~isempty(linsys.C(:,:,end)),'Problem in the output of the "linearize" command. Check your IO for linearization')
    if strcmp(opt.spec_space,'Y')
        pf = linsys.C(:,:,end)*(nearest_point_on_s - critical_point_on_pred);
    else
        pf = nearest_point_on_s - critical_point_on_pred;
    end
    du = zeros(size(TU));
    du(1:length(TU_critical)) = optimal_descent(linsys, TU_critical,0:linearized_timed_step:critical_t, pf);
    U = arrayfun(@(x) min(staliro_InputBounds(2),max(x,staliro_InputBounds(1))),U+h*(staliro_InputBounds(2)-staliro_InputBounds(1))*du'/norm(du)); 
end
    u_saved = [TU;U_saved'];
end