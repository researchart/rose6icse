% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = findOptimalMappingForTrivialBlocks( infoIn )
%findOptimalMappingForTrivialBlocks Finds the core to assign trivial blocks

info = infoIn;

% Copy mapping information from cpu assignment array to a list of mappings
info.blockMappingList = cell(info.numOfBlocks, 0);
info.blockMappingList{info.numOfBlocks} = [];
for i = 1:info.numOfBlocks
    blockMapping = info.cpuAssignmentArrayForBlocks(i);
    if blockMapping > 0
        if ~isempty(setdiff(info.ancestorsList{i}, -1)) %Some top level blocks may have their ancestors set as '-1', remove '-1's.
            setToMap = [i, info.ancestorsList{i}]; % Add this mapping to block itself and all of its ancestors mapping list.
            for j = setToMap
                if isempty(find(info.blockMappingList{j} == blockMapping, 1))
                    info.blockMappingList{j} = [info.blockMappingList{j}, blockMapping];
                end
            end
        end
    end
end

%If a block is unmapped but one of its ancestors has a certain mapping, then map that block to same
%core with that ancestor.
for i = 1:info.numOfBlocks
    if isempty(info.blockMappingList{i}) %not mapped
        ancestors = setdiff(info.ancestorsList{i}, -1);
        if ~isempty(ancestors)
            for j = ancestors
                if numel(info.blockMappingList{j}) == 1 %there is an ancestor mapped to only one core
                    info.blockMappingList{i} = info.blockMappingList{j};
                    break;
                end
            end
        end
    end
end

portDepMatrix = findDependencies(info.portsGraph);
for i = 1:numel(info.ports)
    if isempty(find(info.portsGraph(:, i), 1)) %No incoming connection -> it is a source
        srcMapping = info.blockMappingList{info.ports(i).block};
        unMapped = [];
        allNodes = [i, find(portDepMatrix(i, :))];
        
        differentMaps = [];
        for j = allNodes
            if numel(info.blockMappingList{info.ports(j).block}) == 1
                differentMaps = [differentMaps, info.blockMappingList{info.ports(j).block}];
            end
        end
        differentMaps = unique(differentMaps);
        if numel(differentMaps) == 1
            for j = allNodes
                if isempty(info.blockMappingList{info.ports(j).block})
                    info.blockMappingList{info.ports(j).block} = differentMaps(1);
                end
            end
        else
            if ~isempty(srcMapping)
                for j = allNodes
                    if info.ports(j).type == 1 && numel(info.blockMappingList{info.ports(j).block}) ~= 1 %input & not has a specific mapping
                        unMapped = [unMapped, j]; %unMapped array will contain all unmapped 'Input' type ports
                    end
                end

                if ~isempty(unMapped)
                    %Find all possible combinations of mapping of ports
                    possiblePortMappings = cell(numel(unMapped), 1);
                    for j = 1:numel(unMapped)
                        possiblePortMappings{j} = srcMapping; %Mapping of source port is always a possible mapping for port j
                        for k = find(portDepMatrix(unMapped(j), :)) %ports depending on port j
                            dependentMapping = info.blockMappingList{info.ports(k).block};
                            if numel(dependentMapping) == 1
                                if isempty(find(possiblePortMappings{j} == dependentMapping(1), 1))
                                    % there is a dependent which is mapped to another core than current possible
                                    % mappings. Add this to possibilities.
                                    possiblePortMappings{j} = [possiblePortMappings{j}, dependentMapping];
                                end
                            end
                        end
                    end
                    allPossibleMaps = cartesianProduct(possiblePortMappings); %Combinations of possible mappings of all unmapped ports

                    %Find best combination of the mappings of the ports
                    bestMapping = 0;
                    bestMappingDepth = 1000;
                    bestNumOfSwitches = 1000; %an irrelevant high value
                    tmpSize = size(allPossibleMaps);
                    for mappingIndex = 1:tmpSize(1)
                        numOfSwitches = 0;
                        breakDepth = 0;
                        for k = allNodes
                            if info.ports(k).type == 0 % port k is an output
                                blockMapping = info.blockMappingList{info.ports(k).block};
                                if numel(blockMapping) ~= 1 %if port itself is not mapped, take the mapping from its predecessor
                                    pred = find(info.portsGraph(:, k));
                                    if numel(pred) == 1
                                        if numel(info.blockMappingList{info.ports(pred).block}) == 1 %Has a certain mapping
                                            blockMapping = info.blockMappingList{info.ports(pred).block}(1);
                                        else
                                            indexInUnMapped = find(unMapped == pred, 1);
                                            blockMapping = allPossibleMaps(mappingIndex, indexInUnMapped);
                                        end
                                    else
                                        fprintf('Unexpected ports connection\n');
                                    end
                                end
                                dst = find(info.portsGraph(k, :));
                                dstMaps = [];
                                for m = dst
                                    if numel(info.blockMappingList{info.ports(m).block}) == 1
                                        tempDstMap = info.blockMappingList{info.ports(m).block};
                                    else
                                        indexInUnMapped = find(unMapped == m, 1);
                                        tempDstMap = allPossibleMaps(mappingIndex, indexInUnMapped);
                                    end
                                    dstMaps = [dstMaps, tempDstMap];
                                end
                                newSwitchCount = numel(unique(setdiff(dstMaps, [0, blockMapping])));
                                numOfSwitches = numOfSwitches + newSwitchCount;
                                if newSwitchCount > 0
                                    if info.blockDepths(info.ports(k).block) > breakDepth
                                        breakDepth = info.blockDepths(info.ports(k).block);
                                    end
                                end
                            end
                        end
                        if numOfSwitches < bestNumOfSwitches
                            bestMapping = mappingIndex;
                            bestNumOfSwitches = numOfSwitches;
                            bestMappingDepth = breakDepth;
                        elseif numOfSwitches == bestNumOfSwitches && breakDepth < bestMappingDepth
                            bestMapping = mappingIndex;
                            bestMappingDepth = breakDepth;
                        elseif numOfSwitches == bestNumOfSwitches && breakDepth == bestMappingDepth
                            bestMapping = [bestMapping, mappingIndex];
                        end
                    end
                    bestMapping = bestMapping(1); %Select one of equal best mappings.
                    for k = allNodes
                        if isempty(info.blockMappingList{info.ports(k).block})
                            indexInUnMapped = find(unMapped == k, 1);
                            if allPossibleMaps(bestMapping, indexInUnMapped) > 0
                                info.blockMappingList{info.ports(k).block} = allPossibleMaps(bestMapping, indexInUnMapped);
                            else
                                pred = find(info.portsGraph(:, k));
                                if numel(pred) == 1
                                    if numel(info.blockMappingList{info.ports(pred).block}) == 1 %Has a certain mapping
                                        info.blockMappingList{info.ports(k).block} = info.blockMappingList{info.ports(pred).block};
                                    else
                                        indexInUnMapped = find(unMapped == pred, 1);
                                        info.blockMappingList{info.ports(k).block} = allPossibleMaps(bestMapping, indexInUnMapped);
                                    end
                                else
                                    fprintf('Unexpected ports connection\n');
                                end
                            end
                        end
                    end
                end
            else
                fprintf('src has no mapping port:%d, block: %d\n', i, info.ports(i).block);
            end
        end
    end
end

%Do mapping of DataStoreMemory blocks
% For performance, take the DataStore Read/Write blocks only.
blocksToCheck = [];
for i = 2:info.numOfBlocks
    blkType = get_param(info.blockList{i}, 'BlockType');
    if strcmpi(blkType, 'DataStoreWrite') || strcmp(blkType, 'DataStoreRead')
        blocksToCheck = [blocksToCheck, i];
    end
end
for i = 1:info.numOfBlocks
    if isempty(info.blockMappingList{i})
        blkType = get_param(info.blockList{i}, 'BlockType');
        if strcmpi(blkType, 'DataStoreMemory')
            dataStoreName = get_param(info.blockList{i}, 'DataStoreName');
            for j = blocksToCheck
                dataStoreName_j = get_param(info.blockList(j), 'DataStoreName');
                if strcmpi(dataStoreName, dataStoreName_j)
                    info.blockMappingList{i} = info.blockMappingList{j};
                    break;
                end
            end
        end
    end
end

end

