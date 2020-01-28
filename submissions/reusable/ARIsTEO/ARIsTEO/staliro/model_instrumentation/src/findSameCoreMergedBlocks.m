% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [info] = findSameCoreMergedBlocks(infoIn)
%findSameCoreMergedBlocks marks the blocks that must go to same core

try
    info = infoIn;
    sameCoreList = cell(0,0);
    sameCoreConn = zeros(info.numOfMergedBlocks);
    
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
        fprintf('%d\n', i);
        for j = sameCoreList{i}
            mainForJ = findCorrespondingMergedBlock(j, info);
            if mainForJ <= 0 % Can not find if this block was discarded.
                for p = info.ancestorsList{j}
                    mainForJ = findCorrespondingMergedBlock(p, info);
                    if mainForJ > 0
                        break;
                    end
                end
            end
            for k = setdiff(sameCoreList{i}, j)
                mainForK = findCorrespondingMergedBlock(k, info);
                if mainForK <= 0 % Can not find if this block was discarded.
                    for p = info.ancestorsList{k}
                        mainForK = findCorrespondingMergedBlock(p, info);
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
    
    %Every block inside desired depth blocks will go into same core
    blocksOfDesiredDepth = getBlocksOfDesiredDepth(info);
    for i = 1:info.numOfMergedBlocks
        sameCoreBlocks = [];
        block = info.mergedBlockIndices{i}(1);
        blockDepth = info.blockDepths(block);
        if blockDepth > info.desiredDepth
            sameCoreBlocks = block;
            desiredDepthAncestor = intersect(blocksOfDesiredDepth, info.ancestorsList{block});
            if numel(desiredDepthAncestor) == 1
                for j = i+1:info.numOfMergedBlocks
                    secondBlock = info.mergedBlockIndices{j}(1);
                    if ~isempty(find(info.ancestorsList{secondBlock} == desiredDepthAncestor, 1)) % block j has same ancestor as block i.
                        sameCoreConn(i, j) =1;
                        break;
                    end
                end
            else
                fprintf('WARNING! mismatch in ancestorslist!\n');
            end
        end
%         if numel(sameCoreBlocks) > 1
%             sameCoreList{end+1} = sameCoreBlocks;
%         end
    end
    
    info.sameCoreMainBlocks = sameCoreConn;
catch
    error('ERROR: findSameCoreMergedBlocks failed!');
end
end

