% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
v=ver('Matlab'); 
if(isequal(v.Release,'(R2017a)'))

    model = 'AbstractFuelControl_M1prev';
else
    if(isequal(v.Release,'(R2018a)'))
        model = 'AbstractFuelControl_M1_2018a';
    else
        model = 'AbstractFuelControl_M1';
    end
end
form_id=2;
% load_specs_and_model;
i=0;
eta = 1;
% parameter h used for event definition
h = 0.05;
% parameter related to the period of the pulse signal
zeta_min = 5;

Ut = 0.008;

low=8.8;
high=40;

taus = 10 + eta;
i = i+1;
preds(i).str = 'low'; % for the pedal input signal
preds(i).A =  [0 0 1] ;
preds(i).b =  low ;
i = i+1;

preds(i).str = 'high'; % for the pedal input signal
preds(i).A =  [0 0 -1] ;
preds(i).b =  -high ;
i = i+1;
% rise event is represented as low/\<>_(0,h)high
% fall event is represented as high/\<>_(0,h)low
preds(i).str = 'norm'; % mode < 0.5 (normal mode = 0)
preds(i).A =  [0 1 0] ;  
preds(i).b =  0.5 ;
i = i+1;
preds(i).str = 'pwr'; % mode >0.5 (power mode = 1)
preds(i).A =  [0 -1 0] ;
preds(i).b =  -0.5 ;
i = i+1;
preds(i).str = 'utr'; % u<=Ut
preds(i).A =  [1 0 0] ;
preds(i).b =  Ut ;
i = i+1;
preds(i).str = 'utl'; % u>=-Ut
preds(i).A =  [-1 0 0] ;
preds(i).b =  Ut ;
i = i+1;

% nform = 0;
% nform  = nform+1;
phi = ['[]_(' num2str(taus) ', inf)(!((low/\<>_(0,' num2str(h) ')high) \/ (high/\<>_(0,' num2str(h) ')low)))'];
% nform  = nform+1;   % close-loop pulse response (formula 27)
% specification.phi =['[]_(' num2str(taus) ', inf)(((low/\<>_(0,' ...
%             num2str(h) ')high) \/ (high/\<>_(0,' num2str(h) ')low))' ...
%             '-> []_[' num2str(eta) ', ' num2str(zeta_min) '](utr /\ utl))'];
% 

opt.SampTime = 0.05;
opt.interpolationtype= {'const', 'pconst'};


sim_time=50;
en_speed=1000;
measureTime=1;
fault_time=60;
spec_num=1;
fuel_inj_tol=1;
MAF_sensor_tol=1;
AF_sensor_tol=1;
sim_time=50;
en_speed=1000;
measureTime=1;
fault_time=60;
spec_num=1;
fuel_inj_tol=1;
MAF_sensor_tol=1;
AF_sensor_tol=1;
sim_time=50;
en_speed=1000;
measureTime=1;
fault_time=60;
spec_num=1;
fuel_inj_tol=1;


MAF_sensor_tol =1;


AF_sensor_tol=1;

sim_time=50;
input_range = [900  1100; 0 61.1]; 
cp_array=[1;10]; 
init_cond = [];
% opt.optim_params.n_tests = 100;
simTime=sim_time;

