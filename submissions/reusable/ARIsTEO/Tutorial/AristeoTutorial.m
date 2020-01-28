% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  

numexec=20;

aristeotime=zeros(1,numexec);
aristeosim=zeros(1,numexec);
aristeosuccess=0;

stalirotime=zeros(1,numexec);
stalirosim=zeros(1,numexec);
stalirosuccess=0;
for i=1:1:numexec
    disp('Running ARISTEO');
    SettingUp
    aristeostarttime=tic;
    [resultsaristeo,inputaristeo] = aristeo(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, opt);
    aristeotime(i)=toc(aristeostarttime);

    aristeosim(i)=resultsaristeo.run(1).nTests;
    opt.optim_params.n_tests=10000;
    if(resultsaristeo.run(1).bestRob<0)
        disp('faulty input found');
        
        aristeosuccess=aristeosuccess+1;
    else
        disp('No faulty input found');
    end
    disp('END ----------------------------');
    clearvars model init_cond  input_range cp_array phi preds sim_time opt results
    
    SettingUp
    disp('Running S-Taliro');
    aristeostoptime=tic;
    [resultsstaliro,inputstaliro] = staliro(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, opt);
    stalirotime(i)=toc(aristeostoptime);
stalirosim(i)= resultsstaliro.run.nTests;
    if(resultsstaliro.run(1).bestRob<0)
            
        disp('faulty input found');
        stalirosuccess=stalirosuccess+1;
    else
        disp('no faulty input found');
    end
    disp('END ----------------------------');

    clearvars model init_cond  input_range cp_array phi preds sim_time opt results
end

disp('****************************');
disp('Results');
disp('****************************');
disp(strcat('Aristeo Time:',num2str(mean(aristeotime))));
disp(strcat('STaliro Time:',num2str(mean(stalirotime))));


disp(strcat('Aristeo #Simulations:',num2str(mean(aristeosim))));
disp(strcat('STaliro #Simulations:',num2str(mean(stalirosim))));

disp(strcat('Aristeo Success:',num2str((aristeosuccess/numexec*100)),'%'));
disp(strcat('STaliro Success:',num2str((stalirosuccess/numexec*100)),'%'));