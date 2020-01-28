% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ config ] = readArchitectureConfig( configFile )
%readArchitectureConfig Read config from given .mat file

config_semaphoreSize = 4;
config_alignment = 4;
config_startAddresses = 0;
config_endAddresses = 1000;
try
    load(configFile);
catch
    fprintf('!!! Could not read config file: %s.\n', configFile);
end
try
    config.semaphoreSize = config_semaphoreSize;
    config.alignmentSize = config_alignment;
    config.totalSharedMemory = 0;
    config.startAddresses = config_startAddresses;
    config.endAddresses = config_endAddresses;
    for i = 1:numel(config_startAddresses)
        config.totalSharedMemory = config.totalSharedMemory + hex2dec(config_endAddresses{i}) - hex2dec(config_startAddresses{i});
    end
    if config.totalSharedMemory < 0
        fprintf('WARNING!!! Incorrect config file. Check start - end addresses !\n');
        config.totalSharedMemory = 0;
    end
catch
    fprintf('Configuration information in ');
    fprintf('%s is incorrect.\n', configFile);
end
end

