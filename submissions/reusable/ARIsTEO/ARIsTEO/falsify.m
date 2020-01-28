% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
 function  [input,robustness]=falsify(abstractedmodel,init_cond, input_range, cp_array, phi, preds, TotSimTime, opt)
    global m
    
            disp('Falsifying');
             disp(datestr(now));
    m=abstractedmodel;
    opt.black_box = 1;
    opt.runs=1;
    if(isnan(abstractedmodel))
         warning('No faulty input found by the falsification procedure');
         input=[];
         robustness=100;
    else
        try
            [res, ~, ~, input] = staliro(@blackbox_exec_identified_model,init_cond, input_range, cp_array, phi, preds, TotSimTime,opt);
            robustness=res.run.bestRob;

        catch exception
            warning(exception.message);
            warning('No faulty input found by the falsification procedure');
            input=[];
        end
        robustness=100;
    end
           
end


