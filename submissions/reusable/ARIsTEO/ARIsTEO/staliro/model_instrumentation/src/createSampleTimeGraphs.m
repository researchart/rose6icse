% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = createSampleTimeGraphs( infoIn )
%createSampleTimeGraphs Create port and block dep graphs for each sample
%time

try
    info = infoIn;
    
    %Initialize to empty
    info.sampleTimeFullDataDepGraph = cell(numel(info.sampleTimes), 0);
    info.sampleTimeFullDataDepGraph{numel(info.sampleTimes)} = [];
    info.sampleTimePorts = cell(numel(info.sampleTimes), 0);
    info.sampleTimePorts{numel(info.sampleTimes)} = [];
    info.sampleTimeMainDataDepGraph = cell(numel(info.sampleTimes), 0);
    info.sampleTimeMainDataDepGraph{numel(info.sampleTimes)} = [];
    info.sampleTimeMainPorts = cell(numel(info.sampleTimes), 0);
    info.sampleTimeMainPorts{numel(info.sampleTimes)} = [];
    info.sampleTimeMainBlocks = cell(numel(info.sampleTimes), 0);
    info.sampleTimeMainBlocks{numel(info.sampleTimes)} = [];
    info.sampleTimeMainBlocksGraph = cell(numel(info.sampleTimes), 0);
    info.sampleTimeMainBlocksGraph{numel(info.sampleTimes)} = [];
    
    portsToKeep = cell(numel(info.sampleTimes), 0);
    portsToKeep{numel(info.sampleTimes)} = [];

    %Determine ports to keep
    for i = 1:numel(info.ports)
        block = info.ports(i).block;
        for sampleTimeIndex = 1:numel(info.sampleTimes)
            if ~isempty(find(info.sampleTimeSets{sampleTimeIndex} == block, 1))
                portsToKeep{sampleTimeIndex} = [portsToKeep{sampleTimeIndex}, i];
            end
        end
    end
    
    %Prune full graph for each sample time
    for sampleTimeIndex = 1:numel(info.sampleTimes)
        info.sampleTimeFullDataDepGraph{sampleTimeIndex} = info.fullDataDepGraph(portsToKeep{sampleTimeIndex},portsToKeep{sampleTimeIndex});
        info.sampleTimePorts{sampleTimeIndex} = info.ports(portsToKeep{sampleTimeIndex});
    end
    
    portsToKeep = cell(numel(info.sampleTimes), 0);
    portsToKeep{numel(info.sampleTimes)} = [];
    
    %Determine ports to keep for main ports
    for i = 1:numel(info.mainPorts)
        block = info.mainPorts(i).block;
        for sampleTimeIndex = 1:numel(info.sampleTimes)
            if ~isempty(find(info.sampleTimeSets{sampleTimeIndex} == block, 1))
                portsToKeep{sampleTimeIndex} = [portsToKeep{sampleTimeIndex}, i];
            end
        end
    end
    
    %Prune full graph for each sample time
    for sampleTimeIndex = 1:numel(info.sampleTimes)
        info.sampleTimeMainDataDepGraph{sampleTimeIndex} = info.mainDataDepGraph(portsToKeep{sampleTimeIndex},portsToKeep{sampleTimeIndex});
        info.sampleTimeMainPorts{sampleTimeIndex} = info.mainPorts(portsToKeep{sampleTimeIndex});
    end
    
    blocksToKeep = cell(numel(info.sampleTimes), 0);
    blocksToKeep{numel(info.sampleTimes)} = [];
    
    %Determine main blocks to keep
    for i = 1:numel(info.mainBlocks)
        block = info.mainBlocks(i);
        for sampleTimeIndex = 1:numel(info.sampleTimes)
            if ~isempty(find(info.sampleTimeSets{sampleTimeIndex} == block, 1))
                blocksToKeep{sampleTimeIndex} = [blocksToKeep{sampleTimeIndex}, i];
            end
        end
    end
    
    %Prune full graph for each sample time
    for sampleTimeIndex = 1:numel(info.sampleTimes)
        info.sampleTimeMainBlocksGraph{sampleTimeIndex} = info.mainBlocksGraph(blocksToKeep{sampleTimeIndex},blocksToKeep{sampleTimeIndex});
        info.sampleTimeMainBlocks{sampleTimeIndex} = blocksToKeep{sampleTimeIndex};
    end
catch
    error('ERROR: createSampleTimeGraphs failed!');
end

end

