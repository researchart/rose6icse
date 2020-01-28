% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [info] = findSameCoreBlocks(infoIn)
%findSameCoreBlocks marks the blocks that must go to same core

try
    info = infoIn;
    sameCoreList = cell(0,0);
    sameCoreConn = zeros(info.numOfMainBlocks);
    
    % For performance, take the DataStore Read/Write blocks only.
    blocksToCheck = [];
    sameCoreBlocks = [];
    for i = 2:info.numOfBlocks
        blkType = get_param(info.blockList{i}, 'BlockType');
        if strcmpi(blkType, 'DataStoreWrite') || strcmp(blkType, 'DataStoreRead')
            blocksToCheck = [blocksToCheck, i];
        elseif strcmpi(blkType, 'Inport') || strcmp(blkType, 'Outport') %input and output port of model itself will be on same core
            if info.parentIndices(i) == 1 %port of the model itself
                sameCoreBlocks = [sameCoreBlocks, i];
            end
        end
    end
    if numel(sameCoreBlocks) > 1
        sameCoreList{end+1} = sameCoreBlocks;
    end
    
    for i = 1:numel(info.ports)
        if info.ports(i).type > 1 %If / enable etc.
            sameCoreBlocks = info.ports(i).block;
            pred = find(info.portsGraph(:, i));
            for j = 1:numel(pred)
                sameCoreBlocks = [sameCoreBlocks, info.ports(pred(j)).block];
            end
            if numel(sameCoreBlocks) > 1
                sameCoreList{end+1} = sameCoreBlocks;
            end
        end
    end
    
    %Every block inside desired depth blocks will go into same core
    blocksOfDesiredDepth = getBlocksOfDesiredDepth(info);
    for i = blocksOfDesiredDepth
        sameCoreBlocks = [];
        for j = 1:info.numOfBlocks
            if ~isempty(find(info.ancestorsList{j} == i, 1)) % block j has block i as an ancestor.
                sameCoreBlocks = [sameCoreBlocks, j];
            end
        end
        if numel(sameCoreBlocks) > 1
            sameCoreList{end+1} = sameCoreBlocks;
        end
    end
    
    % Create a list where each entry has blocks that will be mapped to same
    % core with each other.
    blocksChecked = [];
    for i = blocksToCheck
        blocksChecked = [blocksChecked, i];
        dataStoreName = get_param(info.blockList{i}, 'DataStoreName');
        blocksToSearch = setdiff(blocksToCheck, blocksChecked);
        sameCoreBlocks = i;
        for j = blocksToSearch
            dataStoreName_j = get_param(info.blockList(j), 'DataStoreName');
            if strcmpi(dataStoreName, dataStoreName_j)
                sameCoreBlocks = [sameCoreBlocks, j];
                blocksChecked = [blocksChecked, j];
            end
        end
        if numel(sameCoreBlocks) > 1
            sameCoreList{end+1} = sameCoreBlocks;
        end
    end
    
    % Using the list created above, find corresponding main blocks and
    % mark same core blocks on a matrix.
    for i = 1:numel(sameCoreList)
        for j = sameCoreList{i}
            mainForJ = 0;
            for m = 1:info.numOfMainBlocks
                if ~isempty(find(info.mainBlockIndices{m} == j, 1))
                    mainForJ = m;
                    break;
                end
            end
            if mainForJ == 0 % Can not find if this block was discarded.
                for p = info.ancestorsList{j}
                    for m = 1:info.numOfMainBlocks
                        if ~isempty(find(info.mainBlockIndices{m} == p, 1))
                            mainForJ = m;
                            break;
                        end
                    end
                    if mainForJ > 0
                        break;
                    end
                end
            end
            for k = setdiff(sameCoreList{i}, j)
                mainForK = 0;
                for m = 1:info.numOfMainBlocks
                    if ~isempty(find(info.mainBlockIndices{m} == k, 1))
                        mainForK = m;
                        break;
                    end
                end
                if mainForK == 0 % Can not find if this block was discarded.
                    for p = info.ancestorsList{k}
                        for m = 1:info.numOfMainBlocks
                            if ~isempty(find(info.mainBlockIndices{m} == p, 1))
                                mainForK = m;
                                break;
                            end
                        end
                        if mainForK > 0
                            break;
                        end
                    end
                end
                
                if mainForJ ~= mainForK && mainForJ > 0 && mainForK > 0
                    sameCoreConn(mainForJ, mainForK) = 1;
                end
            end
        end
    end
    info.sameCoreList = sameCoreList;
    info.sameCoreMainBlocks = sameCoreConn;
catch
    error('ERROR: findSameCoreBlocks failed!');
end
end

