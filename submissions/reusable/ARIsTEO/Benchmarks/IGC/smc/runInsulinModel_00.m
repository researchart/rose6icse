% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
    
clear;

nSims = input ('how many runs would you like to perform? ')
par_ver = input ('use parallel version (1) or not (0)? ')

mdl='insulinGlucoseSimHumanCtrl_00'; 

if par_ver
        
    %% You cannot plot inside a parfor
    %     n_of_workers = 8;
%     matlabpool(n_of_workers);
    matlabpool
    n_of_workers = matlabpool('size');
    parfor ipar = 1:n_of_workers
    
       cwd = pwd;
       addpath(cwd)
       tmpdir = [mdl,num2str(ipar)];
       mkdir(tmpdir)
       cd(tmpdir)
       load_system(mdl)
       set_param(mdl, 'SimulationMode', 'rapid')
       rtp = Simulink.BlockDiagram.buildRapidAcceleratorTarget(mdl);
       
        for i = 1: nSims/n_of_workers
            parameterSet = Simulink.BlockDiagram.modifyTunableParameters(rtp,...
                'calibError', -0.3 + 0.6*rand, ...
                'sTime_actual', 80*rand,...
                'mDuration_actual', 20+30*rand, ...
                'carbs_actual', 100+200*rand, ... 
                'gi_actual', 20+50*rand, ...
                'correctionBolusTime', 150+100*rand );

%             parameterSet = Simulink.BlockDiagram.modifyTunableParameters(rtp,...
%                 'calibError', 0.2*rand, ...
%                 'sTime_actual', 40*( 0.5 + rand),...
%                 'mDuration_actual', 30*(0.5 + rand), ...
%                 'carbs_actual', 200*(0.2+2*rand), ... 
%                 'gi_actual',30*(0.5 + rand));

            simout = sim(mdl, 'SimulationMode','rapid', ...
                'RapidAcceleratorUpToDateCheck', 'off', ...
                'SaveFormat','StructureWithTime',...
                'SaveOutput','on','OutputSaveName','yout',...
                'LimitDataPoints','off',...
                'RapidAcceleratorParameterSets',parameterSet);

            sigout = get(simout,'yout');

        end

%         cd(cwd)
%         rmdir(tmpdir,'s')
%         rmpath(cwd)        
    end
    
    matlabpool close

    
else
    
    figure(1);
    clf
    
    subplot(1,3,1);
    rectangle('Position',[0 2 180 20]);
    hold on;
    rectangle('Position',[180 2 300 9],'FaceColor','r');
    subplot(1,3,3);
    rectangle('Position',[0 2 180 25]);
    hold on;
    rectangle('Position',[180 2 300 9],'FaceColor','r');

    load_system(mdl)
    set_param(mdl, 'SimulationMode', 'rapid')
    rtp = Simulink.BlockDiagram.buildAcceleratorTarget(mdl);
    
    for i = 1: nSims
        
            parameterSet = Simulink.BlockDiagram.modifyTunableParameters(rtp,...
                'calibError', -0.3 + 0.6*rand, ...
                'sTime_actual', 80*rand,...
                'mDuration_actual', 20+30*rand, ...
                'carbs_actual', 100+200*rand, ... 
                'gi_actual', 20+50*rand, ...
                'correctionBolusTime', 150+100*rand );

            simout = sim(mdl, 'SimulationMode','rapid', ...
                'SaveFormat','StructureWithTime',...
                'SaveOutput','on','OutputSaveName','yout',...
                'LimitDataPoints','off',...
                'RapidAcceleratorParameterSets',parameterSet);
        
        sigout = get(simout,'yout');
        
        figure(1);
        hold on
        subplot(1,3,1)
        plot(sigout.time,sigout.signals(1).values);
        hold on
        subplot(1,3,2)
        plot(sigout.time,sigout.signals(2).values);
        hold on
        subplot(1,3,3)
        plot(sigout.time,sigout.signals(3).values);
        
    end

        %%
        figure(1);
        hold on
        subplot(1,3,1)
        title('Plasma Glucose');
        xlabel('Time (mins)');
        ylabel('Plasma Glucose Conc. (mmol/L)');
        hold on
        subplot(1,3,2)
        title('Plasma Insulin');
        xlabel('Time (mins)');
        ylabel('Plasma Insulin Conc. (U/L)');
        hold on
        subplot(1,3,3)
        title('CGM reading');
        xlabel('Time (mins)');
        ylabel('Subcutaneous Glucose Conc. (mmol/L)');
        
    %% Reference Simulation without any errors
        
    simout = sim(mdl, 'SaveFormat','StructureWithTime',...
        'SaveOutput','on','OutputSaveName','yout',...
        'LimitDataPoints','off');
    
    sigout = get(simout,'yout');
  
    hold on
    subplot(1,3,1)
    plot(sigout.time,sigout.signals(1).values,'--k^','LineWidth',2);
    title('Plasma Glucose');
    hold on
    subplot(1,3,2)
    plot(sigout.time,sigout.signals(2).values,'--k^','LineWidth',2);
    title('Plasma Insulin');
    hold on
    subplot(1,3,3)
    plot(sigout.time,sigout.signals(3).values,'--k^','LineWidth',2);
    title('CGM reading');

end
