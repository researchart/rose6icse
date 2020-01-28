% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% NAME
% 
%     abstract
% 
% SYNOPSYS
%    
%     [data, abstractedmodel] = abstract(model,init_cond,input_range,cp_array,TotSimTime,aristeo_options)
%     
% DESCRIPTION
% 
%     Simulate the input inputModel, starting at the provided initial conditions, and with the provided control input and computes an abstraction of the model.
%     
%     INPUTS
%
%     model
%         The model to be considered. Can be a function handle, an object of class hautomaton, or a simulink .mdl model.
%         In the last case, inputModel is of data type string.
%         
%     OUTPUTS
function [data, abstractedmodel, X0, idOptions] = abstract(model,init_cond,input_range,cp_array,TotSimTime,aristeo_options)
         
    %% checks that the parameters are correctly set
    global staliro_opt;
    staliro_opt=aristeo_options;
    if(strcmp(aristeo_options.abstraction_algorithm,'arx')==0 && strcmp(aristeo_options.abstraction_algorithm,'armax')==0 && strcmp(aristeo_options.abstraction_algorithm,'bj')==0 && strcmp(aristeo_options.abstraction_algorithm,'tf')==0 && strcmp(aristeo_options.abstraction_algorithm,'ss')==0 && strcmp(aristeo_options.abstraction_algorithm,'nlarx')==0 && strcmp(aristeo_options.abstraction_algorithm,'hw')==0)
        error(strcat('The model structure ',aristeo_options.abstraction_algorithm,' is currently not supported by the abstraction procedure'));
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'arx') && (isequal(aristeo_options.na,-1) || isequal(aristeo_options.nb,-1) || isequal(aristeo_options.nk,-1)))
         error('If you are using the arx abstraction algoritm, the value of aristeo_options.na, aristeo_options.nb, aristeo_options.nc must be set');
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'armax') && (isequal(aristeo_options.na,-1) || isequal(aristeo_options.nb,-1) || isequal(aristeo_options.nc,-1) || isequal(aristeo_options.nk,-1)))
         error('If you are using the arx abstraction algoritm, the value of aristeo_options.na, aristeo_options.nb, aristeo_options.nc, aristeo_options.nk must be set');
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'bj') && (isequal(aristeo_options.nb,-1) || isequal(aristeo_options.nc,-1) || isequal(aristeo_options.nf,-1) || isequal(aristeo_options.nd,-1) || isequal(aristeo_options.nk,-1)))
         error('If you are using the arx abstraction algoritm, the value of aristeo_options.nb, aristeo_options.nc, aristeo_options.nf, aristeo_options.nd, aristeo_options.nk must be set');
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'tf') && (isequal(aristeo_options.np,-1) || isequal(aristeo_options.nz,-1)))
         error('If you are using the tf abstraction algoritm, the value of aristeo_options.np, aristeo_options.nz, must be set');
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'ss') && isequal(aristeo_options.nx,-1))
         error('If you are using the ss abstraction algoritm, the value of aristeo_options.nx must be set');
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'nlarx') && (isequal(aristeo_options.na,-1) || isequal(aristeo_options.nb,-1) || isequal(aristeo_options.nk,-1)))
         error('If you are using the ss abstraction algoritm, the value of aristeo_options.na, aristeo_options.nb, aristeo_options.nk must be set');
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'hw') && (isequal(aristeo_options.nb,-1) || isequal(aristeo_options.nf,-1) || isequal(aristeo_options.nk,-1)))
         error('If you are using the ss abstraction algoritm, the value of aristeo_options.nb, aristeo_options.nf, aristeo_options.nk  must be set');
    end
    
    %% Generates the first input of the simulation    
    if ~isempty(init_cond) 
        InitialState= rand(size(init_cond,1),1).*(init_cond(:,2)-init_cond(:,1))+init_cond(:,1);
    else
        InitialState=[];
    end
    
    global simtime;
    
    UPoint=generateUPoint(cp_array,input_range);
    
        disp('Abstract');
     disp(datestr(now));
    simtimetic=tic;
    [hs, ~, sigData] = systemsimulator(model, InitialState, UPoint, TotSimTime, input_range, cp_array, aristeo_options);
    simtime=toc(simtimetic);
    
    disp('Resampling');
     disp(datestr(now));

    v=ver('Matlab'); 
    if(isequal(v.Version,'7.11'))
        if(hs.T(2,1)>staliro_opt.SampTime)
            val= ceil(hs.T(2,1)/staliro_opt.SampTime);
            YT=hs.YT;
            YT=resample(YT,val,1);            
        else
            val= ceil(staliro_opt.SampTime/hs.T(2,1));
            YT=hs.YT;
            YT=resample(YT,1,val);  
        end
        if(sigData(2,1)>staliro_opt.SampTime)
            val= ceil(sigData(2,1)/staliro_opt.SampTime);
            U=sigData(:,2:1:size(sigData,2));
            U=resample(U,val,1);
        else
            val= ceil(staliro_opt.SampTime/sigData(2,1));
            U=sigData(:,2:1:size(sigData,2));
            U=resample(U,1,val);
        end
        minrow=min(size(YT,1),size(U,1));
        data=iddata(YT(1:1:minrow,:),U(1:1:minrow,:),aristeo_options.SampTime);
    else    
        YT=hs.YT;
        YT=resample(YT,hs.T,1/staliro_opt.SampTime);
        U=sigData(:,2:1:size(sigData,2));
        U=resample(U,sigData(:,1),1/staliro_opt.SampTime);
        minrow=min(size(YT,1),size(U,1));
        data=iddata(YT(1:1:minrow,:),U(1:1:minrow,:),aristeo_options.SampTime);
    end
    
    data = misdata(data);

    global absreftime;

    X0=[];    
    absreftimetic=tic;
    X0=[];
    
        disp('Abstracting');
         disp(datestr(now));
    
    try
    if(strcmp(aristeo_options.abstraction_algorithm,'arx'))

      v=ver('Matlab');
      if(isequal(v.Version,'7.11'))
          idOptions=[];
          abstractedmodel=arx(data,[aristeo_options.na aristeo_options.nb aristeo_options.nk],'Focus','simulation');
      else
          if(size(aristeo_options.na,1)==1)
              idOptions = arxOptions('EnforceStability',true,'InitialCondition','estimate','Focus','simulation');
          else
              idOptions = arxOptions('InitialCondition','estimate','Focus','simulation');
          end
          abstractedmodel=arx(data,[aristeo_options.na aristeo_options.nb aristeo_options.nk],idOptions);
        end
    end
    if(strcmp(aristeo_options.abstraction_algorithm,'armax'))
      idOptions = armaxOptions('EnforceStability',true,'InitialCondition','estimate','Focus','simulation');
      abstractedmodel=armax(data,[aristeo_options.na aristeo_options.nb aristeo_options.nc aristeo_options.nk],idOptions);
    end
    if(strcmp(aristeo_options.abstraction_algorithm,'bj'))
      try
        idOptions = bjOptions('EnforceStability',true,'InitialCondition','estimate','Focus','simulation');
        abstractedmodel=bj(data,[aristeo_options.nb aristeo_options.nc aristeo_options.nd aristeo_options.nf aristeo_options.nk],idOptions);
      catch exception
          idOptions = bjOptions('EnforceStability',true,'InitialCondition','estimate','Focus','simulation');
          abstractedmodel=NaN;
      end    
    end
    if(strcmp(aristeo_options.abstraction_algorithm,'tf'))
      idOptions = tfestOptions('EnforceStability',true,'InitialCondition','estimate','Focus','simulation');
      abstractedmodel=tfest(data,aristeo_options.np,aristeo_options.nz,idOptions,'Ts',data.Ts);
    end 
    if (strcmp(aristeo_options.abstraction_algorithm,'ss'))
        if(isequal(v.Version,'7.11'))
          idOptions=[];
          abstractedmodel=pem(data,'nx',aristeo_options.nx,'Focus','stability');
        else
        idOptions = ssestOptions('EnforceStability',true,'InitialState','estimate');
        [abstractedmodel, X0]=ssest(data,aristeo_options.nx,idOptions);
        X0=[X0 X0];
        end
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'nlarx'))
       idOptions = nlarxOptions('Focus','simulation');
       idOptions.SearchOptions.MaxIter = 2;
       idOptions.Focus = 'simulation';
       idOptions.SearchMethod = 'lm';
       idOptions.SearchOptions.Advanced.LMStep=2;
              idOptions.SearchOptions.Advanced.MaxFunctionEvaluations=2;
      [abstractedmodel]=nlarx(data,[aristeo_options.na aristeo_options.nb aristeo_options.nk],wavenet('num',1),idOptions);
    end
    if (strcmp(aristeo_options.abstraction_algorithm,'hw'))
       idOptions = nlhwOptions();
       idOptions.SearchOptions.MaxIterations = 2;
        idOptions.SearchMethod = 'lm';
           idOptions.SearchOptions.Advanced.LMStep=2;
      [abstractedmodel]=nlhw(data,[aristeo_options.nb aristeo_options.nf aristeo_options.nk]);
    end
    absreftime=toc(absreftimetic);
    catch e
        absreftime=toc(absreftimetic);
        warning(e.message);,
        abstractedmodel=[];
        
    end
end


