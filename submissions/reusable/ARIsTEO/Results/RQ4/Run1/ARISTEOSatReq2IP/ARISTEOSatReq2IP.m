% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
clc;
close all;
clear;

ADCS_performance;
sim_time=t_fin;

tool='ARISTO';
  
model='ESAIL_implem_validation_v128';

global aaaa;
aaaa=1;


input_range = [-10 50]; 
n_cp=16;

    
cp_array=n_cp;
init_cond = [];

phi='[]_[35000,85800]([]_[0,600] p))';

preds.str='p';
preds.A=1;
preds.b=3;



opt=aristeo_options();
opt.taliro_undersampling_factor=10;
opt.n_refinement_rounds=10;
opt.runs=1;
opt.abstraction_algorithm='bj';

opt.nb=2;
opt.nc=2;
opt.nf=2;
opt.nd=2;
opt.nk=0;
opt.nx=2;
opt.optim_params.n_tests=10;
opt.SampTime=sim_time_step;                                       
opt.interpolationtype = {'pchip'};
opt.init_identification_time=35000;

timer=tic;
 disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('RQ3:   ARISTEO');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(phi)
[results, sigData]=aristeo(model,init_cond, input_range, cp_array,  phi, preds, sim_time, opt);
% [results, sigData]=staliro(model,init_cond, input_range, cp_array,  phi, preds, sim_time, opt);
  time=toc(timer);
disp(results.run.bestRob);
disp(time);
save('workspace');
%end