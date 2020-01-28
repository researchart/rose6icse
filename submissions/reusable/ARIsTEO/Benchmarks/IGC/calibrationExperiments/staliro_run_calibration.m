% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function staliro_run_calibration(mDuration, mGI)
% This is the main file to run S-Taliro on the insulin glucose simulation
% problem.
% 
% (C) Sriram Sankaranarayanan 2012 - University of Colorado, Boulder



model = 'insulinGlucoseSimHumanCalibration';
warning off all
init_cond = [];

input_range = [
    0.01 0.3; % icRatio
    -40 40; % iStartLoGI
    -40 40; %iStartMedGI
    -40 40; %iStartHiGI
    3 40; %bWLo
    3 40; %bWMid
    3 40; %bWHi
    3  100; %sensFactor
    ];  
 



cp_array=[1 1 1 1 1 1 1 1];

disp(' Blood glucose calibration code ')
disp(' (C) Sriram Sankaranarayanan 2012, University of Colorado, Boulder ')
disp(' All rights reserved. ')
disp(' ')



fName = ['output_',num2str(mGI),'_',num2str(mDuration),'.txt']
fID = fopen (fName,'a');

fprintf (fID, 'meal GI: %f meal Duration: %f\n',mGI, mDuration);

set_param('insulinGlucoseSimHumanCalibration/duration','value',num2str(mDuration));
set_param('insulinGlucoseSimHumanCalibration/mGI','value',num2str(mGI));


disp('The specification:')
phi = '!([] a /\ []_[200,400.0] b)'
preds(1).str = 'a';
disp('Type "help monitor" to see the syntax of MTL formulas')
preds(1).A = [1 0 0; -1 0 0];
preds(1).b = [12; -4];
preds(2).str = 'b';
preds(2).A = [1 0 0; -1 0 0];
preds(2).b = [7; -5];

disp(' ')
disp('Total Simulation time:')
time = 400;
disp(time);
opt = staliro_options();

opt.spec_space='Y';
opt.interpolationtype={'const'};
%%opt.optimization_solver='CE_Taliro';
% 
% [rob,runtime,~,samples] = staliro(model, init_cond, input_range, cp_array, phi, preds,time,opt);
% 
% for i = 1:opt.runs
%    [T,~,Y,IT] = SimSimulinkMdl(model, [0 cp_array],samples(i,:),time,opt);
%    figure ;
% %%   title('Run #'+num2str(i));
%   %% subplot(1,3,1);
%   %% plot(T , Y(:,1) );
%   %% subplot(1,3,2);
%   %% plot(T, Y(:,2));
%   %% subplot(1,3,3);
%   %% plot(T, Y(:,3));
%    
%    disp ('Best input for simulation run # ')
%    disp(i)
%    disp('Robustness ')
%    disp(rob(i));
%    disp('Input');
%    disp(IT(1,2:9));
%   
%    disp('icRatio: ');
%    disp(IT(1,2));
%    disp('Starting Time ( GI <= 10) : ');
%    disp(IT(1,3));
%    disp('Starting Time (GI : (10,20]):');
%    disp(IT(1,4));
%    disp('Starting Time GI: (20,...)');
%    disp(IT(1,5));
%    disp('bolus width: (GI <= 10):');
%    disp(IT(1,6));
%    disp('bolus width: (GI : (10,20])');
%    disp(IT(1,7));
%    disp('bous width: (GI > 20) ');
%    disp(IT(1,8));
%    disp('sensitivity factor for correction');
%    disp(IT(1,9));
%    
%    fprintf (fID,'Run number %d\n',i);
%    fprintf (fID,'Robustness Value: %f \n',rob(i));
%    fprintf (fID,'Run time: %f \n',runtime(i));
%    fprintf (fID,'Parameters: \n');
%    fprintf (fID,'\t icRatio: %f \n',IT(1,2));
%    fprintf (fID,'\t Insulin Sensitivity Factor for correction bolus: %f \n',IT(1,9));
%    if (mGI <= 10)
%        fprintf(fID, '\t Insulin Start Time ( GI <= 10) : %f \n', IT(1,3));
%        fprintf (fID, '\t Bolus Width (GI <= 10): %f \n', IT(1,6));
%    else
%        if (mGI <= 20)
%           fprintf(fID, '\t Insulin Start Time ( GI  (10,20] ) : %f \n', IT(1,4));
%           fprintf (fID, '\t Bolus Width (GI (10,20] ): %f \n', IT(1,7));
%        else
%           fprintf(fID, '\t Insulin Start Time ( GI > 20) : %f \n', IT(1,5));
%           fprintf (fID, '\t Bolus Width (GI > 20): %f \n', IT(1,8));
%        end
%    end
%    
%    
% end

disp('Running Cross Entropy Method');
opt.optimization_solver='CE_Taliro';
opt.optim_params.n_tests=500;

nRuns = 10;
opt.runs=1;
for i = 1:nRuns
    [rob,runtime,~,samples] = staliro(model, init_cond, input_range, cp_array, phi, preds,time,opt);
    [T,~,Y,IT] = SimSimulinkMdl(model, [0 cp_array],samples(1,:),time,opt);
   %figure ;
  % subplot(1,3,1);
  % plot(T , Y(:,1) );
  % subplot(1,3,2);
  % plot(T, Y(:,2));
  % subplot(1,3,3);
 %  plot(T, Y(:,3));
   
   disp ('Best input for simulation run # ')
   disp(i)
   disp('Robustness ')
   disp(rob(1));
   disp('Input');
   disp(IT(1,2:9));
  
   disp('icRatio: ');
   disp(IT(1,2));
   disp('Starting Time ( GI <= 10) : ');
   disp(IT(1,3));
   disp('Starting Time (GI : (10,20]):');
   disp(IT(1,4));
   disp('Starting Time GI: (20,...)');
   disp(IT(1,5));
   disp('bolus width: (GI <= 10):');
   disp(IT(1,6));
   disp('bolus width: (GI : (10,20])');
   disp(IT(1,7));
   disp('bous width: (GI > 20) ');
   disp(IT(1,8));
   disp('sensitivity factor for correction');
   disp(IT(1,9));
   
   fprintf (fID,'Run number %d\n',i);
   fprintf (fID,'Robustness Value: %f \n',rob(1));
   fprintf (fID,'Run time: %f \n',runtime(1));
   fprintf (fID,'Parameters: \n');
   fprintf (fID,'\t icRatio: %f \n',IT(1,2));
   fprintf (fID,'\t Insulin Sensitivity Factor for correction bolus: %f \n',IT(1,9));
   if (mGI <= 10)
       fprintf(fID, '\t Insulin Start Time ( GI <= 10) : %f \n', IT(1,3));
       fprintf (fID, '\t Bolus Width (GI <= 10): %f \n', IT(1,6));
   else
       if (mGI <= 20)
          fprintf(fID, '\t Insulin Start Time ( GI  (10,20] ) : %f \n', IT(1,4));
          fprintf (fID, '\t Bolus Width (GI (10,20] ): %f \n', IT(1,7));
       else
          fprintf(fID, '\t Insulin Start Time ( GI > 20) : %f \n', IT(1,5));
          fprintf (fID, '\t Bolus Width (GI > 20): %f \n', IT(1,8));
       end
   end
   
   
end


fclose(fID);
end
