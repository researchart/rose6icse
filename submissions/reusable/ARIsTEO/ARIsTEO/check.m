% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [data,robustness]=check(model,cp_array,input_range,init_cond,input,phi,preds,data,TotSimTime,aristeo_options)
    %% Simulating the original model with the new input
    global aristeo_options_backup;
    global simtime;
    global RUNSTATS;
    RUNSTATS.new_run();
    simopt = simget(model);
    
    if ~isempty(init_cond) 
        InitialState= rand(size(init_cond,1),1).*(init_cond(:,2)-init_cond(:,1))+init_cond(:,1);
        simopt = simset(simopt, 'InitialState', InitialState);
    else
        InitialState=[];
    end
     if ~strcmp(aristeo_options.ode_solver, 'default')
        simopt = simset(simopt, 'Solver', aristeo_options.ode_solver);
    end
    
    load_system(model)
    
    if(isempty(input) || sum(sum(isnan(input(:,:))))>0 || sum(sum(isinf(input(:,:))))>0 )
        UPoint=generateUPoint(cp_array,input_range);
        opt=aristeo_options_backup;
        simtimetic=tic;
        [hs, ~, input] = systemsimulator(model, InitialState, UPoint, TotSimTime, input_range, cp_array, opt);
         simtime=toc(simtimetic);
         YT=hs.YT;
         T=hs.T;
    else
        simtimetic=tic;
        [T, ~, YT] = sim(model, [0 TotSimTime], simopt, input);
        simtime=toc(simtimetic);
    end
    
    v=ver('Matlab'); 
    if(isequal(v.Version,'7.11'))
        if(input(2,1)>aristeo_options.SampTime)
            val= ceil(input(2,1)/aristeo_options.SampTime);
            input=input(:,2:1:size(input,2));
            input=resample(input,val,1);
        else
            val= ceil(aristeo_options.SampTime/input(2,1));
            input=input(:,2:1:size(input,2));
            input=resample(input,1,val);
        end 
        robustness = dp_taliro(phi, preds, YT, T);

           if(YT(2,1)>aristeo_options.SampTime)
                val= ceil(YT(2,1)/aristeo_options.SampTime);
                YT=hs.YT;
                YT=resample(YT,val,1);            
           else
                val= ceil(aristeo_options.SampTime/hs.T(2,1));
                YT=hs.YT;
                YT=resample(YT,1,val);  
           end
           minrow=min(size(YT,1),size(input,1));
           d=iddata(YT(1:1:minrow,:),input(1:1:minrow,:),aristeo_options.SampTime);
           data = merge(data,d);

   else 
       input=resample(input(:,2:size(input,2)),input(:,1),1/aristeo_options.SampTime);

       robustness = dp_taliro(phi, preds, YT, T);

       if ((aristeo_options.fals_at_zero==0 && robustness>=0) || (aristeo_options.fals_at_zero==1 && robustness>0))
           YT=resample(YT,T,1/aristeo_options.SampTime);
           minrow=min(size(YT,1),size(input,1));
           d=iddata(YT(1:1:minrow,:),input(1:1:minrow,:),aristeo_options.SampTime);
           data = merge(data,d);
       end
    end
end

