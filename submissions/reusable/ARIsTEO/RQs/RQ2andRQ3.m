% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function []=RQ2andRQ3(tool,max_MUT_executions)

    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp('RQ1 - RQ2:   S-Taliro vs ARISTEO');
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
     

    %% Reads the inputs from a file
    [num,txt,raw]  = xlsread('Inputs.xlsx');
    %reads the first column of the file
    folders=raw(2:1:size(raw,1),1);
    %reads the second column of the file
    scriptsrunningmodels=raw(2:1:size(raw,1),2);
    %reads the third column of the file
    nTests=cell2mat(raw(2:1:size(raw,1),3));

    
    nTestsInputs=cell2mat(raw(2:1:size(raw,1),4));
    nTestsOutputs=cell2mat(raw(2:1:size(raw,1),5));

    %% Preparing the datastructures from the experiment
    modelStructure='bj';
    numberofexamples=size(scriptsrunningmodels,1);
    % 9 abstraction refinement rounds correspond to 10 executions of the
    % original model
    expnum=100;

    fid = fopen(strcat('./Results/RQ2/rq2results',tool,'.csv'),'w'); % removes old content from rq3results.txt
    fprintf(fid,'%s,%s,%s\n','Experiment','Approach','SuccessPercentage');            
    fclose(fid);
     % creates the header of the file
    fid = fopen(strcat('./Results/RQ3/rq3resultsIterations',tool,num2str(max_MUT_executions),'.csv'),'w'); 
    fclose(fid);
   

    %% Running the experiment
    for experiment=1:1:numberofexamples
        scriptname=scriptsrunningmodels{experiment};
        disp('*************************************');    
        disp(strcat('Model:  ',scriptname));

        %% configuring ARISTEO and STALIRO
        if (strcmp(tool,'aristeo')==1)
            opt=aristeo_options();
            
            opt.abstraction_algorithm=modelStructure;
            opt.n_refinement_rounds=max_MUT_executions;
            opt.optim_params.n_tests=nTests(experiment);
            
            ninputs=nTestsInputs(experiment);
            noutputs=nTestsOutputs(experiment);

            opt.nb=ones(noutputs,ninputs)*2;
            opt.nf=ones(noutputs,ninputs)*2;
            opt.nk=ones(noutputs,ninputs)*0;
            opt.nc=ones(noutputs,1)*2;
            opt.nd=ones(noutputs,1)*2;
                        
        end    
        if (strcmp(tool,'staliro')==1)
            opt=staliro_options();
            % set the maximum number of executiosn of the original model of
            % S-Taliro
            opt.optim_params.n_tests=max_MUT_executions;
        end
        opt.runs=expnum;


        %% Running the considered model

        eval(scriptname);
        evalin('base',scriptname);
        func= str2func(strcat('@',tool));
        [results,input]=func(model, init_cond, input_range, cp_array, phi, preds, sim_time, opt);

        %% Processing the results
        faultyRows = find([results.run.bestRob] < 0);
        successPercentage=length(faultyRows);

        disp('Success percentage');
        disp(successPercentage);
        
        % writes the results on a file
        fid = fopen(strcat('./Results/RQ2/rq2results',tool,'_',num2str(max_MUT_executions),'.csv'),'a');
        fprintf(fid,'%s,%s,%s\n',tool,folders{experiment},num2str(successPercentage));            
        fclose(fid);

        AverageIterations=mean([results.run(faultyRows).nTests]);        
        disp(strcat('#',tool));
        disp(AverageIterations);

       
        a=[results.run(faultyRows).nTests];
        fid = fopen(strcat('./Results/RQ3/rq3resultsIterations',tool,num2str(max_MUT_executions),'.csv'),'a');
        fprintf(fid,'%d\t',a);
        fprintf(fid,'\n');
        fclose(fid);

        
        % clear the variables for the next iterations
        clearvars model init_cond  input_range cp_array phi preds sim_time opt results 
        clearvars -except numberofexamples experiment tool max_MUT_executions folders scriptsrunningmodels nTests nTestsInputs nTestsOutputs modelStructure numberofexamples expnum
    end
    cd('..');
    cd('RQs');

end
