% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = reduceToMainPorts( infoIn )
%reduceToMainPorts Discard ports of trivial blocks (Flatten the model)

try
    info = infoIn;
    
    info.mainBlockIndices = cell(info.numOfBlocks, 1);
    for i = 1:info.numOfBlocks
        info.mainBlockIndices{i} = i;
    end
    info.mainPortsGraph = info.portsGraph;
    info.mainPorts = info.ports;
    portsToRemove = [];
    blocksToRemove = 1;
    for i = 1:numel(info.ports)
        blockIndex = info.ports(i).block;
        willRemove = checkIfDiscardBlock(info, blockIndex);
        if willRemove
            portsToRemove = [portsToRemove, i];
            if isempty(find(blocksToRemove == blockIndex, 1))
                blocksToRemove = [blocksToRemove, blockIndex];
            end
            srcs = find(info.mainPortsGraph(:, i));
			srcs = srcs.';
            dsts = [];
            
            if strcmpi(info.blockTypeList{blockIndex}, 'Goto')
                froms = findCorrespondingFroms(info, blockIndex);
                blocksToRemove = [blocksToRemove, froms];
                for j = froms
                    [fromPort, portExists, ~] = getIndexOfPort(info.ports, j, 0, 1);
                    if portExists
                        portsToRemove = [portsToRemove, fromPort];
                        dsts = [dsts, find(info.mainPortsGraph(fromPort, :) ~= 0)];
                    else
                        fprintf('WARNING! reduceToMainPorts: port related to from could not be found!\n');
                    end
                end
            else
                dsts = find(info.mainPortsGraph(i, :));
            end
            
            for j = srcs
                for k = dsts
                    info.mainPortsGraph(j, k) = 1;
                end
            end
        end
    end
    
    %Now remove ports
    portsToRemove = unique(portsToRemove);
    allPorts = 1:numel(info.ports);
    remainingPorts = setdiff(allPorts, portsToRemove);
    info.mainPorts = info.mainPorts(remainingPorts);
    info.mainPortsGraph = info.mainPortsGraph(remainingPorts, :);
    info.mainPortsGraph = info.mainPortsGraph(:, remainingPorts);
    
    info.mainBlocksGraph = zeros(length(info.blocksGraph));
    for i = 1: numel(info.mainPorts)
        edgeCost = info.mainPorts(i).edgeCost;
        if isempty(edgeCost) % For action port to inport connections
            edgeCost = 1;
        end
        blockIndex = info.mainPorts(i).block;
        dsts = find(info.mainPortsGraph(i, :));
        for j = dsts
            dstBlockIndex = info.mainPorts(j).block;
            info.mainBlocksGraph(blockIndex, dstBlockIndex) = edgeCost;
        end
    end
    
    % We treat DataStoreMemory blocks separately because they have no ports and will not be handled
    % by the code above.
    for i = 1:length(info.mainBlocksGraph)
        blockIndex = info.mainBlockIndices{i}(1);
        if strcmpi(info.blockTypeList{blockIndex}, 'DataStoreMemory')
            blocksToRemove = [blocksToRemove, blockIndex];
        end
    end
    
    %remove blocks
    blocksToRemove = unique(blocksToRemove);
    allBlocks = 1:info.numOfBlocks;
    remainingBlocks = setdiff(allBlocks, blocksToRemove);
    info.mainBlockIndices = info.mainBlockIndices(remainingBlocks);
    info.mainBlocksGraph = info.mainBlocksGraph(remainingBlocks, :);
    info.mainBlocksGraph = info.mainBlocksGraph(:, remainingBlocks);
    info.numOfMainBlocks = length(info.mainBlocksGraph);
catch
    error('ERROR: reduceToMainPorts failed!');
end
end

