% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [T, XT, YT, LT, CLG, Guards] = GDBlackbox(X0,simT,TU,U) %#ok<INUSL>
% script created for S-Taliro to simulate its input model 
% the BlackBox interface is fixed.
% inputs:
%       X0: systems initial condition or []
%       simT: simulation time
%       TU: input time vector
%       U: input signal
% relevant outputs:
%       T: time sequence
%       XT: system states
%       YT: system outputs
%
% See also: staliro_options, Apply_Opt_GD_default, GdDoc
%
% (C) 2019, Shakiba Yaghoubi, Arizona State University

global staliro_opt;
LT = [];
CLG = [];
Guards = [];
model = staliro_opt.optim_params.GD_params.model;
open_system(model)
mdlWks = get_param(model,'ModelWorkspace');
assignin(mdlWks,'T',TU')
assignin(mdlWks,'U',U')
simopt = simget(model);
simset(simopt,'SaveFormat','Array','MaxStep', 0.1); % Replace input outputs with structures
[T, XT, YT] = sim(model,[0 simT]);
% save_system(model)
end