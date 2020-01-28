% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
%%
% selectedexperiment: folder that contains the experiment (name of the
% benchmark)
% modelsstructure: model structure to be used in RQ1
% modelorder: index of the model order to be considered
function []=RQ1(selectedexperiment,modelsstructure,currentOrderIndex)
     
    disp(currentOrderIndex);
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp('RQ1:   ARIsTEO');
    if(~isempty(selectedexperiment))
	disp(selectedexperiment)
    end
    if(~isempty(modelsstructure))
	disp(modelsstructure);
	end
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    clearvars -except selectedexperiment modelsstructure currentOrderIndex
    close all
    %setup_staliro;
    
    disp('selected experiment:');
    disp(selectedexperiment);
    curPath=fileparts(which('RQ1.m')); 
    mainpath = strrep(curPath,'RQs',''); 
    addpath(genpath(mainpath));
    %% Reads the inputs from a file
    [num,txt,raw]  = xlsread('Inputs.xlsx');
    %reads the first column of the file
    folders=raw(2:1:length(raw),1);
    %reads the second column of the file
    scriptsrunningmodels=raw(2:1:length(raw),2);
    %reads the third column of the file
    nTests=cell2mat(raw(2:1:length(raw),3));
    
    nTestsInputs=cell2mat(raw(2:1:length(raw),4));
    nTestsOutputs=cell2mat(raw(2:1:length(raw),5));
    
    
    %% Preparing the datastructures from the experiment
    numabstractionrefinement=10; % number of maximum abstraction refinement rounds
    expnum=100; % number of experiments - to be chosen to compute significative results
    maxn=10; % maximum order of the model
    incrementn=2; % increment in the order of the model
    minn=2; % minimum order of the model
    orders = minn:incrementn:maxn;
    
    % contains the considered model structured
    modelsstructures={'arx', 'armax', 'ss', 'bj', 'tf', 'nlarx','hw'};

    % writing the header of the result file
    fid = fopen(strcat('./Results/RQ1/',selectedexperiment,'/',modelsstructure,num2str(currentOrderIndex),'results.csv'),'w');
    fprintf(fid,'%s,%s,%s,%s,%s,%s\n','Experiment','Model','Order','Percentage','AvgIterations','Time');            
    fclose(fid);  

    totalnow = tic();    
   
    for experiment=1:1:size(scriptsrunningmodels,1)
        % opening the right folder
        scriptname=scriptsrunningmodels{experiment};
        
        

        if(isempty(selectedexperiment) || isequal(selectedexperiment,folders{experiment}))
            %% evaluating a given configuration
            
            for modelnumber=1:1:size(modelsstructures,2)
                
                if(isempty(modelsstructure) || isequal(modelsstructure,modelsstructures{modelnumber}))
                    opt=aristeo_options();
                    currentOrder=2;
                    % loading the experiment
                    evalin('base',scriptname);
                    eval(scriptname);

                    ninputs=nTestsInputs(experiment);
                    noutputs=nTestsOutputs(experiment);

                    if(~isempty(modelsstructure))
                        abstractionModelType=modelsstructure;
                    end
                    disp(strcat('Model:  ',scriptname,' Abstraction: ',abstractionModelType,' n: ', num2str(orders(currentOrder))));

                    opt.n_refinement_rounds=numabstractionrefinement;
                    opt.optim_params.n_tests=1;
                    opt.abstraction_algorithm=abstractionModelType;
                    opt.runs=expnum;
                    % running ARISTEO
                    %for currentOrderIndex=1:size(orders,2)
                        now = tic();
                        
			disp(currentOrderIndex);
			currentOrder=orders(str2num(currentOrderIndex));
                        disp(num2str(currentOrder));
                        opt=aristeo_options();
                        % loading the experiment
                        evalin('base',scriptname);
                        eval(scriptname);
                        
                        
                        ninputs=nTestsInputs(experiment);
                        noutputs=nTestsOutputs(experiment);
                
                        
                        abstractionModelType=modelsstructures{modelnumber};
                        disp(strcat('Model:  ',scriptname,' Abstraction: ',abstractionModelType,' n: ', num2str(currentOrder)));
                        
                        
                        opt.nx=currentOrder;
                        opt.na=ones(noutputs,noutputs)*currentOrder;
                        opt.nb=ones(noutputs,ninputs)*currentOrder;
                        opt.nf=ones(noutputs,ninputs)*currentOrder;
                        opt.nk=ones(noutputs,ninputs)*0;
                        opt.nc=ones(noutputs,1)*currentOrder;
                        opt.nd=ones(noutputs,1)*currentOrder;
                        opt.np=ones(noutputs,ninputs)*currentOrder;
                        opt.nz=ones(noutputs,ninputs)*currentOrder;
                        opt.n_refinement_rounds=numabstractionrefinement;
                        opt.optim_params.n_tests=nTests(experiment);
                        opt.runs=expnum;
            			opt.abstraction_algorithm=abstractionModelType;
			
                        % loading the experiment
                        evalin('base',scriptname);
                        eval(scriptname);

                        if(isequal(folders{experiment},'IGC') &&(isequal(abstractionModelType,'nlarx')||isequal(abstractionModelType,'hw')))
                             opt.optim_params.n_tests=100;
                        end
                        % running ARISTEO
                        [results,input]=aristeo(model,init_cond, input_range, cp_array,  phi, preds, sim_time, opt);

                        % computing the results
                        faultyRows = find([results.run.bestRob] < 0);
                        Percentage=length(faultyRows)/expnum*100;
                        AverageIterations=mean([results.run(faultyRows).nTests]);           
                        time=toc(now);

                        % saving the results
                        fid = fopen(strcat('./Results/RQ1/',selectedexperiment,'/',modelsstructures{modelnumber},num2str(currentOrderIndex),'results.csv'),'a');
                        fprintf(fid,'%s,%s,%d,%4f,%4f,%4f\n',folders{experiment},abstractionModelType,currentOrder,Percentage,AverageIterations,time);
                        fclose(fid);

                        % clears the variable to ensure obtaining a correct result in
                        % the next iteration
                        clearvars -except currentOrderIndex totalnow nTestsInputs nTestsOutputs noutputs expnum modelsstructure selectedexperiment folders scriptsrunningmodels  nTests numabstractionrefinement expnum orders modelsstructures experiment modelnumber currentOrder scriptname
                        bdclose('all');
                     %end
                    
                    disp("Total execution time: ");

                    totaltime=toc(totalnow);
                    display(totaltime);
    
                    fid = fopen(strcat('./Results/RQ1/',selectedexperiment,'/',modelsstructures{modelnumber},num2str(currentOrderIndex),'Statistics.txt'),'w');
                    fprintf(fid,'%4f\n',totaltime);            
                    fclose(fid);
                end
                
                
            end
        
           
            
        end
        cd ../;
    end
      
end

