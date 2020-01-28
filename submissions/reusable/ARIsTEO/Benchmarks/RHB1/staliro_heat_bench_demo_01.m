% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% S-Taliro script for the Heat Benchmark from the HSCC 04 paper by Fehnker & Ivancic
v=ver('Matlab'); 
if(isequal(v.Release,'(R2017a)'))
    model = 'heat25830_staliro_01prev';
else
    if(isequal(v.Release,'(R2018a)'))    
        model = 'heat25830_staliro_01_2018a';
    else
        model = 'heat25830_staliro_01';
    end
end
    
load heat30;

phi = '[]p';
preds(1).str = 'p';
preds(1).A = -eye(10);
preds(1).b = -[14.50; 14.50; 13.50; 14.00; 13.00; 14.00; 14.00; 13.00; 13.50; 14.00];

opt.SampTime=0.05;
opt.interpolationtype={'pchip'};

cp_array=4;
sim_time = 24;
init_cond = [17*ones(10,1) 18*ones(10,1)];
%input_range=[-2 5];
input_range=[1 2];
% opt.optim_params.n_tests = 100;

% opt.optim_params.n_tests = 100;
simTime=sim_time;






