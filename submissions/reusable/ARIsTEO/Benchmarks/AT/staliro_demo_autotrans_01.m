% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% This is a demo for using S-TALIRO with the Automatic Transimssion
% Simulink Demo.
%
% Demo for falsifying the specification '!(<>r1 /\ <>r2)' 
% The predicates r1 and r2 correspond to the sets R1 and R2 in the paper:
% Zhao, Q.; Krogh, B. H. & Hubbard, P. Generating Test Inputs for Embedded 
% Control Systems IEEE Control Systems Magazine, 2003, August, 49-57

% (C) G. Fainekos 2011 - Arizona State Univeristy
v=ver('Matlab'); 
if(isequal(v.Release,'(R2017a)'))

    model = 'sldemo_autotrans_mod01prev';
else
    if(isequal(v.Release,'(R2018a)'))
        model = 'sldemo_autotrans_mod01_2018a';
    else
        model = 'sldemo_autotrans_mod01';
    end
end
phi = '!(<>r1 /\ <>r2)' ;

ii = 1;
preds(ii).str='r1';
preds(ii).A = [-1 0];
preds(ii).b = -120;
preds(ii).loc = 1:7;

ii = ii+1;
preds(ii).str='r2';
preds(ii).A = [0 -1];
preds(ii).b = -4500;
preds(ii).loc = 1:7;

opt.SampTime=0.04;
opt.interpolationtype={'pconst'};


sim_time=30;
input_range = [0 100];
cp_array=7;
init_cond = [];
% opt.optim_params.n_tests =1000;
simTime=sim_time;


