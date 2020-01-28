% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [nearest_point_on_s, tmin, rob, ixmin, critical_point_on_pred] = staliro_critical_info(SP,XT,YT,T,opt)

% This function outputs the critical information that is used for
% calculating the robustness value:
%
% Inputs:
% SP: Includes information about MTL formula 
% XT: System states
% YT: System output
% T: time trace
% opt: Staliro_options
%
% Outputs:
% nearest_point_on_s: The critical point on the state trajectory/output
% tmin: critical time 
% rob: robustness value
% ixmin: the index corresponding to critical information
% critical_point_on_pred: The closest point on the unsafe predicates to the
% trajectory/output
%
% See also: staliro, staliro_options, SA_Taliro_parameters, Apply_Opt_GD_default
%
% (C) 2019, Shakiba Yaghoubi, Arizona State University

% This function needs to be merged with compute_robustness function. Aux info is
% missing from compute_robustness function.

    if strcmp(opt.spec_space,'Y')
        [rob, aux] = dp_taliro(SP.phi,SP.pred,YT,T);
    else
        [rob, aux] = dp_taliro(SP.phi,SP.pred,XT,T);
    end
    if aux.i==0
        aux.i=1;
    end
    ixmin = aux.i;
    tmin = T(aux.i);
    i_pr = aux.pred;  %get_predicate_index(aux.predicate,SP.pred);
    if strcmp(opt.spec_space,'Y')
        nearest_Y = YT(aux.i,:)';
        nearest_point_on_s = nearest_Y;
        [~,~,critical_point_on_pred] = SignedDist(nearest_Y,SP.pred(i_pr).A,SP.pred(i_pr).b);
    else
        nearest_point_on_s = XT(aux.i,:)';
        [~,~,critical_point_on_pred] = SignedDist(nearest_point_on_s,SP.pred(i_pr).A,SP.pred(i_pr).b);
    end
end