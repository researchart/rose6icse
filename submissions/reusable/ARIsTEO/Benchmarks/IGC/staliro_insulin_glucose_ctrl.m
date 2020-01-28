% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% This is the main file to run S-Taliro on the insulin glucose simulation
% problem.
% 
% (C) Sriram Sankaranarayanan 2012 - University of Colorado, Boulder
v=ver('Matlab'); 
if(isequal(v.Release,'(R2017a)'))

    model = 'insulinGlucoseSimHumanCtrlprev';
else
    if(isequal(v.Release,'(R2018a)'))
         model = 'insulinGlucoseSimHumanCtrl_2018a';
    else
        model = 'insulinGlucoseSimHumanCtrl';
    end
end
load_system(model);
warning off all
init_cond = [];
input_range = [40 40;   % meal time announced
               30  30;  % meal duration announced
               200 200; % meal carbohydrates
                40 40;   % meal GI factor announced
               150 250; % time for correction bolus administration
                0 80;   % meal time actual
                20 50;  % meal duration actual
                100 300; % meal carbohydrates actual
                20 70;   % meal GI factor actual
                -.3 .3];   % calibration error in CGM monitor

cp_array=[1 1 1 1 1 1 1 1 1 1];

%%disp(' 1. Hypoglycemia  <> G < 3.0 ' )
%disp(' 1. Significant hypoglycemia <> G < 2.0 ')
%disp(' 2. Critical hypoglycemia <> G < 1.0 ');
%disp(' 3. Significant post-prandial glucose excursion <> G > 35.0 ')
%disp(' 4. Failure to settle: <>_{240,400} G >= 12 ')
%disp(' Please select option: ' )
%opt = input( 'Please select an option : ')

%disp('You selected')
%disp(opt)

c=4;
if (c < 1 || c > 4) 
    disp('Not a legal option!')
    return
end


switch c
    case 1
        phi = '[] a';
        preds(1).str='a';
        preds(1).A = [-1 0 0 ];
        preds(1).b = [-2 0 0 ]; 
        propName='Hypoglycemia (G >= 2) ';
        fName='runData-p1.txt';
    case 2
        phi = '[] a';
        preds(1).str='a';
        preds(1).A = [-1 0 0 ];
        preds(1).b = [-1 0 0 ];
        propName='Hypoglycemia (G >= 1) ';
        fName = 'runData-p2.txt'
    case 3
        phi = '[] a';
        preds(1).str = 'a';
        preds(1).A = [1 0 0 ];
        preds(1).b = [35 0 0 ];
        propName='Significant Hyperglycemia (G <= 35) ';
        fName = 'runData-p3.txt';
    case 4
        phi = '[]_[240,400] a';
        preds(1).str='a';
        preds(1).A = [1 0 0 ];
        preds(1).b = [12 0 0 ];
        propName='Hyperglycemia (G <= 12 after time 240 mins) ';
        fName = 'runData-p4.txt';
        

        
        
end

sim_time = 400;
%opt = staliro_options();

%nRuns = input('How many runs would you like?');
%if (nRuns <= 0)
%    nRuns = 1;
%end
%opt.runs = 1;
%disp('I am testing for property')
%disp(propName)

%opt.falsification=0;
opt.spec_space='Y';
opt.interpolationtype={'const'};

opt.optimization_solver = 'SA_Taliro';

simTime=sim_time;
% opt.optim_params.n_tests=1000;


%   [T,~,Y,IT] = SimSimulinkMdl(mdl,init_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample(:,1),time,opt);
