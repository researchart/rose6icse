% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Specification [] G>=3

clear;

    delta = 0.05;
    c = 0.9;

    mdl='insulinGlucoseSimHumanCtrl_00'; 

    alpha=1;
    beta=1;
    
    colors = 'grby';

    n_tests = 0; % total number of tests 
    s_tests = 0; % number of successfull tests  

    % max number of tests (make a parameter in the future)
    max_n_tests = 50000;

    % Start pool for parallel execution
    matlabpool
    n_of_workers = matlabpool('size');
    % initialize workers for rapid simulation
    parfor ipar = 1:n_of_workers
       cwd = pwd;
       addpath(cwd)
       tmpdir = [mdl,num2str(ipar)];
       mkdir(tmpdir)
       cd(tmpdir)
       load_system(mdl)
       set_param(mdl, 'SimulationMode', 'rapid')
       rtp{ipar} = Simulink.BlockDiagram.buildRapidAcceleratorTarget(mdl);
    end
    
    for i=1:max_n_tests/n_of_workers
       
         parfor ipar = 1:n_of_workers

             parameterSet = Simulink.BlockDiagram.modifyTunableParameters(rtp{ipar},...
                'calibError', -0.3 + 0.6*rand, ...
                'sTime_actual', 80*rand,...
                'mDuration_actual', 20+30*rand, ...
                'carbs_actual', 100+200*rand, ... 
                'gi_actual', 20+50*rand, ...
                'correctionBolusTime', 150+100*rand );

            simout = sim(mdl, 'SimulationMode','rapid', ...
                'RapidAcceleratorUpToDateCheck', 'off', ...
                'SaveFormat','StructureWithTime',...
                'SaveOutput','on','OutputSaveName','yout',...
                'LimitDataPoints','off',...
                'RapidAcceleratorParameterSets',parameterSet);

            sigout{ipar} = get(simout,'yout');
            
            % Specification (not through taliro for parallel execution)
            rob(ipar) = min(sigout{ipar}.signals(1).values>=3);

         end
         
%          figure(1)
%          clf
%          for ii = 1:n_of_workers
%              hold on 
%              plot(sigout{ii}.time,sigout{ii}.signals(1).values,colors(ii))
%          end
%          plot([0,500],[3,3],'r')
%          title(num2str(rob))
%          pause
       
       n_tests = n_tests+n_of_workers;                    
       disp(['Number of tests: ',num2str(n_tests)]);
       s_tests = s_tests+sum(rob);     % increase the number of successfull tests
       
       p_h = (s_tests+alpha)/(n_tests+alpha+beta);      % calculates the mean of the posterior distribution
       T = [p_h - delta,p_h + delta];
       
       if T(1,2) > 1 
           T = [1-2*delta,1];
       else if T(1,1) < 0
               T = [0,2*delta];
           end
       end
       
       gamma = betacdf(T(1,2),s_tests+alpha,n_tests-s_tests+beta)-betacdf(T(1,1),s_tests+alpha,n_tests-s_tests+beta);

       if gamma >= c
           posteriorMean = p_h;
           confidenceInt = T;
           break;
       end
    end

    parfor ipar = 1:n_of_workers
       close_system(mdl)
    end
    
    matlabpool close

disp('Posterior Mean:')
posteriorMean

disp('Confidence Interval:')
confidenceInt
