% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ params,rob ] = paramBin(trajs,monotony,parRange,sz,parameter_list,parameter_index)
%PARAMBIN function used to synthesize parameters given a set of
%trajectories

global staliro_mtlFormula;
global staliro_Predicate;
global staliro_opt;

for ii = 1: size(parRange,1)
    if(monotony(ii)>0)
        pb(ii) = parRange(ii,2); %#ok<*AGROW>
        pw(ii) = parRange(ii,1);
    else
        pb(ii) = parRange(ii,1);
        pw(ii) = parRange(ii,2);
    end
end

pred_tmp = staliro_Predicate;

for jj = 1: size(trajs,2)
    
    T = trajs{jj}.T;
    XT = trajs{jj}.XT;
    YT = trajs{jj}.YT;
    
    %% Compute robustness of trajectory
    if staliro_opt.spec_space=='X' && ~isempty(XT)
        STraj = XT;
    elseif staliro_opt.spec_space=='Y' && ~isempty(YT)
        STraj = YT;
    else
        error('S-Taliro: The selected specification space (spec_space) is not supported or the signal space is empty.\n If you are using a "white box" m-function as a model, then you must set the "spec_space" to "X".')
    end
    
    if ~isempty(staliro_opt.dim_proj)
        STraj = STraj(:,staliro_opt.dim_proj);
    end
    
    
    %% Reduce granularity of STraj when too big and causes taliro to run out of memory - REVIEW CAREFULLY
    
    if staliro_opt.taliro_undersampling_factor ~= 1
        STraj = STraj(1:staliro_opt.taliro_undersampling_factor:end,:); 
        T = T(1:staliro_opt.taliro_undersampling_factor:end,:);
    end
    
    %% Compute robustness of trajectory
    if staliro_opt.spec_space=='X' && ~isempty(XT)
        STraj = XT;
    elseif staliro_opt.spec_space=='Y' && ~isempty(YT)
        STraj = YT;
    else
        error('S-Taliro: The selected specification space (spec_space) is not supported or the signal space is empty.\n If you are using a "white box" m-function as a model, then you must set the "spec_space" to "X".')
    end
    
    for ii=1:size(parameter_index,2)
        if parameter_list(parameter_index(ii)) == 2
            pred_tmp(parameter_index(ii)).value = pw(ii);
        elseif parameter_list(parameter_index(ii)) == 3
            pred_tmp(parameter_index(ii)).value = pw(ii);
            pred_tmp(parameter_index(ii)).b = pw(ii);
        else
            error('Staliro: Parameter setting error, check the predicate settings.');
        end
    end
    
    tmp_rob_w(jj) = feval(staliro_opt.taliro, staliro_mtlFormula, pred_tmp, STraj, T);
    
    for ii=1:size(parameter_index,2)
        if parameter_list(parameter_index(ii)) == 2
            pred_tmp(parameter_index(ii)).value = pb(ii);
        elseif parameter_list(parameter_index(ii)) == 3
            pred_tmp(parameter_index(ii)).value = pb(ii);
            pred_tmp(parameter_index(ii)).b = pb(ii);
        else
            error('Staliro: Parameter setting error, check the predicate settings.');
        end
    end
    
    tmp_rob_b(jj) = feval(staliro_opt.taliro, staliro_mtlFormula, pred_tmp, STraj, T);
    
    
end

if all(tmp_rob_w>=0)
    par = pw;
    rob = min(tmp_rob_w);
    %     if opt.verbose
    fprintf(['Warning: Interval contains only sat params, result may be not tight. ' ...
        'Try larger parameter region. \n']);
    %     end
    return;
end

if any(tmp_rob_b<0)
    par = pb; %#ok<*NASGU>
    rob = max(tmp_rob_b);
    fprintf(['Error: Interval contains only unsat params, result not tight. Try larger parameter ' ...
        'region. \n']);
    return;
end

trajs = trajs(find(tmp_rob_w<0)); %#ok<FNDSB>
rob = inf;
for kk = 1:sz
    
    pimax = parRange(kk,2);
    
    pimin = parRange(kk,1);
    
    err = 1;
    
    while (abs(pimax-pimin)>err)
        p_i = (pimax+pimin)/2;
        
        if parameter_list(parameter_index(kk)) == 2
            pred_tmp(parameter_index(kk)).value = p_i;
        elseif parameter_list(parameter_index(kk)) == 3
            pred_tmp(parameter_index(kk)).value = p_i;
            pred_tmp(parameter_index(kk)).b = p_i;
        else
            error('Staliro: Parameter setting error, check the predicate settings.');
        end
        
        for jj = 1: size(trajs,2)
            T = trajs{jj}.T;
            XT = trajs{jj}.XT;
            YT = trajs{jj}.YT;
            LT = trajs{jj}.LT;
            CLG = trajs{jj}.CLG;
            GRD = trajs{jj}.GRD;
            
            %% Compute robustness of trajectory
            if staliro_opt.spec_space=='X' && ~isempty(XT)
                STraj = XT;
            elseif staliro_opt.spec_space=='Y' && ~isempty(YT)
                STraj = YT;
            else
                error('S-Taliro: The selected specification space (spec_space) is not supported or the signal space is empty.\n If you are using a "white box" m-function as a model, then you must set the "spec_space" to "X".')
            end
            
            if ~isempty(staliro_opt.dim_proj)
                STraj = STraj(:,staliro_opt.dim_proj);
            end
            
            
            %% Reduce granularity of STraj when too big and causes taliro to run out of memory - REVIEW CAREFULLY
            
            if staliro_opt.taliro_undersampling_factor ~= 1
                STraj = STraj(1:staliro_opt.taliro_undersampling_factor:end,:);
                T = T(1:staliro_opt.taliro_undersampling_factor:end,:);
            end
            
            %% Compute robustness of trajectory
            if staliro_opt.spec_space=='X' && ~isempty(XT)
                STraj = XT;
            elseif staliro_opt.spec_space=='Y' && ~isempty(YT)
                STraj = YT;
            else
                error('S-Taliro: The selected specification space (spec_space) is not supported or the signal space is empty.\n If you are using a "white box" m-function as a model, then you must set the "spec_space" to "X".')
            end
            
            tmp_rob_b(jj) = feval(staliro_opt.taliro, staliro_mtlFormula, pred_tmp, STraj, T);
        end
        
        val = min(tmp_rob_b);
        
        res = num2str(p_i);
        
        disp(res);
        
        
        if(val>0)
            rob = min(val,rob);
            if(monotony(ii)<0)
                pimin = p_i;
            else
                pimax = p_i;
            end
        else
            if(monotony(ii)<0)
                pimax = p_i;
            else
                pimin = p_i;
            end
        end
        
    end
    
    if(val>0)
        par(kk) = p_i;
    else
        if(monotony(ii)>0)
            par(kk) = pimax;
        else
            par(kk) = pimin;
        end
    end
    
end

params = par;

end

