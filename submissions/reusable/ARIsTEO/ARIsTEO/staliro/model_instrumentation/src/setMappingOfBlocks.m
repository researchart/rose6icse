% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function setMappingOfBlocks( info )
%setMappingOfBlocks Mark each block with its core assignments

newInfo.modelName = info.modelName;
newInfo.modelSearchDepth = info.modelSearchDepth;
try
    [newInfo.blockList, newInfo.wasModelOpenedAlready] = readModelBlockInformation(newInfo.modelName, newInfo.modelSearchDepth);
catch
    fprintf('ERROR: Model ''%s'' could not be loaded.\nBe sure to give model name as a parameter without file extension.\n', newInfo.modelName);
    return;
end

newInfo.handles = readBlockHandles(newInfo.blockList);
newInfo.parentHandles = readParentHandles(newInfo.blockList);
newInfo.blockTypeList = readBlockTypes(newInfo.blockList);
newInfo.whileSubsystemHandles = getListOfWhileSubsystems( newInfo.blockList );

numOfAllblocks = length(newInfo.blockList);
allBlocksList = 2:numOfAllblocks;
connMatrix = generateConnectionsMatrix( newInfo );

mappingOfBlocks = -2 * ones(1, numOfAllblocks);
%startTimeOfBlocks = -1 * ones(1, numOfAllblocks);
mappedList = [];
%First, mark the main blocks that we know the mapping.
try
    for i = 1:info.numOfMainBlocks
        mappedCore = info.cpuAssignmentArrayForBlocks(i);
        setMappingOfBlock(info.simpleBlockList{i}, mappedCore);
        handle = get_param(info.simpleBlockList{i}, 'Handle');
        index = getIndexFromHandle(handle, newInfo.handles);
        mappingOfBlocks(index) = mappedCore;
        %startTimeOfBlocks(index) = info.executionTimesForBlocks(i);
        %wcetOfBlocks(index) = info.orgSimpleWcetArr(i);
        mappedList = [mappedList, index];
    end
catch
    fprintf('ERROR: markBlockCoresOnModel %d\n', i);
end

%Mark everything inside while subsystems to same core
try
    for i = 1:length(newInfo.blockList)
        handle = newInfo.handles(i);
        if mappingOfBlocks(i) == -2
            whileParents = getWhileParents(newInfo, handle);
            for parentHandle = whileParents
                parentIndex = getIndexFromHandle(parentHandle, newInfo.handles);
                if mappingOfBlocks(parentIndex) ~= -2
                    mappedCore = mappingOfBlocks(parentIndex);
                    setMappingOfBlock(newInfo.blockList{i}, mappedCore);
                    mappingOfBlocks(i) = mappedCore;
                    %startTimeOfBlocks(index) = info.executionTimesForBlocks(i);
                    %wcetOfBlocks(index) = info.orgSimpleWcetArr(i);
                    mappedList = [mappedList, i];
                    break;
                end
            end
        end
    end
catch
    fprintf('ERROR: markBlockCoresOnModel %d\n', i);
end

mappedProcessedList = [];
unmappedList = [];
unprocessedMappedList = setdiff(mappedList, mappedProcessedList);
lastPass = 0; %lastPass is for blocks that could not be mapped
while ~isempty(unprocessedMappedList) || lastPass
    while ~isempty(unprocessedMappedList)
        for i = unprocessedMappedList
            if mappingOfBlocks(i) > 0
                for j = 2:numOfAllblocks
                    if connMatrix(i, j) > 0
                        if mappingOfBlocks(j) == -2
                            blockType = newInfo.blockTypeList{j};
                            %blockType = get_param(newInfo.blockList{j}, 'BlockType');
                            if strcmpi(blockType, 'Goto') || strcmpi(blockType, 'Outport')
                                mappingOfBlocks(j) = mappingOfBlocks(i);
%                                 if startTimeOfBlocks(j) < 0 || startTimeOfBlocks(j) > (startTimeOfBlocks(i) + wcetOfBlocks(i))
%                                     startTimeOfBlocks(j) = startTimeOfBlocks(i) + wcetOfBlocks(i);
%                                 end
                                setMappingOfBlock(newInfo.blockList{j}, mappingOfBlocks(j));
                                mappedList = [mappedList, j];
                                if info.isDebugMode > 0
                                    fprintf('+');
                                end
                            end
                        end
                    end
                end
            end
            mappedProcessedList = [mappedProcessedList, i];
        end
        unprocessedMappedList = setdiff(mappedList, mappedProcessedList);
    end
    % Finished marking destinations of mapped blocks
    unmappedList = setdiff(allBlocksList, mappedList);
    numOfUpdates = 1;
    while numOfUpdates > 0
        numOfUpdates = 0;
        for i = unmappedList
            try
                if mappingOfBlocks(i) == -2
                    blockType = newInfo.blockTypeList{i};
                    %blockType = get_param(newInfo.blockList{i}, 'BlockType');
                    if strcmpi(blockType, 'From') || strcmpi(blockType, 'Inport')
                        mappingOfDests = [];
                        %startTimeOfDests = [];
                        for j = 2:numOfAllblocks
                            if connMatrix(i, j) > 0
                                if mappingOfBlocks(j) <= 0
                                    children = checkIfBlockIsAParent(newInfo.handles(j), newInfo.parentHandles);
                                    if ~isempty(children) % Destination block is parent of some other blocks
                                        portsOfSrcBlk = get_param(newInfo.handles(i), 'PortConnectivity');
                                        if ~isempty(portsOfSrcBlk)
                                            for blockPortIndex = 1:length(portsOfSrcBlk) % for each port
                                                if ~isempty(portsOfSrcBlk(blockPortIndex,1).DstBlock) % This is an output port (blockPortIndex)
                                                    for blockDestination = 1:length(portsOfSrcBlk(blockPortIndex,1).DstBlock) % for each destination
                                                        dstBlockIndex = getIndexFromHandle(portsOfSrcBlk(blockPortIndex,1).DstBlock(blockDestination), newInfo.handles); % get index of destination
                                                        if j == dstBlockIndex %This block is the destination block we are looking for
                                                            dstPort = portsOfSrcBlk(blockPortIndex,1).DstPort(blockDestination);
                                                            for k = children
                                                                if strcmpi(newInfo.blockTypeList{k}, 'Inport')
                                                                    if str2double(get_param(newInfo.blockList{k}, 'Port')) == (dstPort + 1)
                                                                        mappingOfDests = [mappingOfDests, mappingOfBlocks(k)];
                                                                        %startTimeOfDests = [startTimeOfDests, startTimeOfBlocks(k)];
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    else
                                        mappingOfDests = [mappingOfDests, mappingOfBlocks(j)];
                                        %startTimeOfDests = [startTimeOfDests, startTimeOfBlocks(j)];
%                                         if mappingOfBlocks(j) == -2
%                                             break;
%                                         end
                                    end
                                else
                                    mappingOfDests = [mappingOfDests, mappingOfBlocks(j)];
                                    %startTimeOfDests = [startTimeOfDests, startTimeOfBlocks(j)];
                                end
                            end
                        end
                        if ~isempty(mappingOfDests)
                            if isempty(find(mappingOfDests <= 0, 1)) && range(mappingOfDests) == 0 %All blocks are mapped to same core
                                mappingOfBlocks(i) = mappingOfDests(1);
                                setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                mappedList = [mappedList, i];
                                numOfUpdates = numOfUpdates + 1;
                                if info.isDebugMode > 0
                                    fprintf('-');
                                end
                                %end
                            elseif lastPass
                                mappedDests = setdiff(mappingOfDests, [-2, 0]);
                                if ~isempty(mappedDests)
                                    if range(mappedDests) == 0 %All mapped destinations are mapped to same core
                                        mappingOfBlocks(i) = mappedDests(1);
                                        setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                        mappedList = [mappedList, i];
                                        numOfUpdates = numOfUpdates + 1;
                                        if info.isDebugMode > 0
                                            fprintf('lp%d>',i);
                                        end
                                    end
                                end
                                if isempty(mappedDests) || (isempty(find(mappingOfDests <= 0, 1)) && range(mappingOfDests) ~= 0) % all destinations are unmapped
                                    if strcmpi(blockType, 'Inport')
                                        portNo = str2double(get_param(newInfo.blockList{i}, 'Port'));
                                        portsOfParent = get_param(newInfo.parentHandles(i), 'PortConnectivity');
                                        srcBlock = portsOfParent(portNo).SrcBlock;
                                        srcBlockIndex = getIndexFromHandle(srcBlock, newInfo.handles);
                                        if mappingOfBlocks(srcBlockIndex) > 0
                                            mappingOfBlocks(i) = mappingOfBlocks(srcBlockIndex);
                                            setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                            mappedList = [mappedList, i];
                                            numOfUpdates = numOfUpdates + 1;
                                            if info.isDebugMode > 0
                                                fprintf('lp%<',i);
                                            end
                                        end
                                    end
                                end
                                
                            end
                        end
%                         tempStartArr = setdiff(startTimeOfDests, -1);
%                         if ~isempty(tempStartArr)
%                             sortedTempStartArr = sort(tempStartArr);
%                             startTimeOfBlocks(i) = sortedTempStartArr(1);
%                         end
                    elseif strcmpi(blockType, 'Goto')
                        mappedthis = 0;
                        gotoTag = cellstr(get_param(newInfo.blockList{i}, 'GotoTag'));
                        gotoVisibility = get_param(newInfo.blockList{i}, 'TagVisibility');
                        gotoParent = newInfo.parentHandles(i);
                        fromMapArr = [];
                        %startTimeOfDests = [];
                        for j = 2:numOfAllblocks % searching corresponding From
                            if strcmpi(newInfo.blockTypeList{j}, 'From') % fromIndex is a From
                                fromTag = cellstr(get_param(newInfo.blockList{j}, 'GotoTag'));
                                if strcmpi(gotoTag, fromTag) % This is a corresponsing "From"
                                    fromParent = newInfo.parentHandles(j);
                                    if strcmpi(gotoVisibility, 'global') == 1 || gotoParent == fromParent % if goto tag visibility is local, then only 'From' tags in same subsystem receives data.
                                        fromMapArr = [fromMapArr, mappingOfBlocks(j)];
                                        %startTimeOfDests = [startTimeOfDests, startTimeOfBlocks(j)];
                                    end
                                end
                            end
                        end
%                         tempStartArr = setdiff(startTimeOfDests, -1);
%                         if ~isempty(tempStartArr)
%                             sortedTempStartArr = sort(tempStartArr);
%                             if startTimeOfBlocks(i) > sortedTempStartArr(1)
%                                 fprintf('TIME MISMATCH\n');
%                             end
%                             if startTimeOfBlocks(i) < 0 || startTimeOfBlocks(i) > sortedTempStartArr(1)
%                                 startTimeOfBlocks(i) = sortedTempStartArr(1);
%                             end
%                         end
                        if ~isempty(fromMapArr)
                            if isempty(find(fromMapArr < 0, 1)) % There is no unmapped from
                                if range(fromMapArr) == 0 % all elements are same
                                    mappingOfBlocks(i) = fromMapArr(1);
                                    setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                    mappedList = [mappedList, i];
                                    numOfUpdates = numOfUpdates + 1;
                                    if info.isDebugMode > 0
                                        fprintf('&');
                                    end
                                    mappedthis = 1;
                                end
                            end
                        end
                        if mappedthis == 0 && lastPass
                            portsOfBlock = get_param(newInfo.handles(i), 'PortConnectivity');
                            srcBlock = portsOfBlock(1,1).SrcBlock;
                            srcPort = portsOfBlock(1,1).SrcPort;
                            children = checkIfBlockIsAParent(srcBlock, newInfo.parentHandles);
                            if ~isempty(children) % Block is parent of some other blocks
                                % parentIndex = getIndexFromHandle(srcBlock, newInfo.handles);
                                %   portsOfParent = get_param(srcBlock, 'PortConnectivity');
                                for j = children
                                    if strcmpi(newInfo.blockTypeList{j}, 'OutPort')
                                        if str2double(get_param(newInfo.blockList{j}, 'Port')) == srcPort + 1;
                                            if mappingOfBlocks(j) > 0
                                                mappingOfBlocks(i) = mappingOfBlocks(j);
%                                                 if startTimeOfBlocks(i) < (startTimeOfBlocks(j) + wcetOfBlocks(j))
%                                                     fprintf('START TIME MISMATCH !!!\n i=%d, j=%d, times: %f - %f\n',i, j, startTimeOfBlocks(i), (startTimeOfBlocks(j) + wcetOfBlocks(j)));
%                                                 end
%                                                 startTimeOfBlocks(i) = startTimeOfBlocks(j) + wcetOfBlocks(j);
                                                setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                                mappedList = [mappedList, i];
                                                numOfUpdates = numOfUpdates + 1;
                                                if info.isDebugMode > 0
                                                    fprintf('lp%d:%d!', i, j);
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    elseif strcmpi(blockType,'TriggerPort') || strcmpi(blockType,'ActionPort') || strcmpi(blockType,'EnablePort') || strcmpi(blockType,'WhileIterator')
                        parentIndex = getIndexFromHandle(newInfo.parentHandles(i), newInfo.handles);
                        if mappingOfBlocks(parentIndex) ~= -2
                            mappingOfBlocks(i) = mappingOfBlocks(parentIndex);
                            setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                            mappedList = [mappedList, i];
                            numOfUpdates = numOfUpdates + 1;
                            if info.isDebugMode > 0
                                fprintf('*');
                            end
                        end
                    elseif strcmpi(blockType, 'DataStoreMemory')
                        dataStoreName = get_param(newInfo.blockList{i}, 'DataStoreName');
                        for j = 2:length(newInfo.blockList)
                            dstBlockType = newInfo.blockTypeList{j};
                            if strcmpi(dstBlockType, 'DataStoreRead') || strcmpi(dstBlockType, 'DataStoreWrite')
                                if strcmpi(dataStoreName, get_param(newInfo.blockList{j}, 'DataStoreName'))
                                    if mappingOfBlocks(j) > 0
                                        mappingOfBlocks(i) = mappingOfBlocks(j);
                                        setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                        mappedList = [mappedList, i];
                                        numOfUpdates = numOfUpdates + 1;
                                        if info.isDebugMode > 0
                                            fprintf('!');
                                        end
                                        break;
                                    end
                                end
                            end
                        end
                    elseif lastPass && strcmpi(blockType,'OutPort')
                        portsOfBlock = get_param(newInfo.handles(i), 'PortConnectivity');
                        srcBlock = portsOfBlock(1,1).SrcBlock;
                        srcPort = portsOfBlock(1,1).SrcPort;
                        children = checkIfBlockIsAParent(srcBlock, newInfo.parentHandles);
                        if ~isempty(children) % Block is parent of some other blocks
                            % parentIndex = getIndexFromHandle(srcBlock, newInfo.handles);
                            %    portsOfParent = get_param(srcBlock, 'PortConnectivity');
                            for j = children
                                if strcmpi(newInfo.blockTypeList{j}, 'OutPort')
                                    if str2double(get_param(newInfo.blockList{j}, 'Port')) == srcPort + 1;
                                        if mappingOfBlocks(j) > 0
                                            mappingOfBlocks(i) = mappingOfBlocks(j);
                                            
%                                             if startTimeOfBlocks(i) < (startTimeOfBlocks(j) + wcetOfBlocks(j))
%                                                     fprintf('START TIME MISMATCH.. !!!\n i=%d, j=%d, times: %f - %f\n',i, j, startTimeOfBlocks(i), (startTimeOfBlocks(j) + wcetOfBlocks(j)));
%                                                 end
%                                             startTimeOfBlocks(i) = startTimeOfBlocks(j) + wcetOfBlocks(j);
                                            setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                            mappedList = [mappedList, i];
                                            numOfUpdates = numOfUpdates + 1;
                                            if info.isDebugMode > 0
                                                fprintf('lp%d:%d!', i, j);
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else
                        children = checkIfBlockIsAParent(newInfo.handles(i), newInfo.parentHandles);
                        if ~isempty(children) % Block is parent of some other blocks
                            childrenMapArr = [];
                            % check if all subblocks are on same core or not
                            for j = children
                                blockType = newInfo.blockTypeList{j};
                                %blockType = get_param(newInfo.blockList{j}, 'BlockType');
                                if lastPass
                                    if mappingOfBlocks(j) > 0 || ...
                                            ~(strcmpi(blockType,'TriggerPort') || strcmpi(blockType,'ActionPort') || strcmpi(blockType,'EnablePort')...
                                            || strcmpi(blockType,'Inport') || strcmpi(blockType,'OutPort') || strcmpi(blockType,'Goto')...
                                            || strcmpi(blockType,'From') || strcmpi(blockType,'WhileIterator'))
                                        childrenMapArr = [childrenMapArr, mappingOfBlocks(j)];
                                    end
                                else
                                    if ~(strcmpi(blockType,'TriggerPort') || strcmpi(blockType,'ActionPort') || strcmpi(blockType,'EnablePort') || strcmpi(blockType,'WhileIterator'))
                                        childrenMapArr = [childrenMapArr, mappingOfBlocks(j)];
                                    end
                                end
                            end
                            if ~isempty(childrenMapArr)
                                if lastPass && isempty(find(childrenMapArr == -2, 1)) && (range(childrenMapArr) == 0)
                                    mappingOfBlocks(i) = childrenMapArr(1);
                                    for j = children
                                        if mappingOfBlocks(j) == -2
                                            mappingOfBlocks(j) = mappingOfBlocks(i);
                                            setMappingOfBlock(newInfo.blockList{j}, mappingOfBlocks(j));
                                            mappedList = [mappedList, j];
                                            numOfUpdates = numOfUpdates + 1;
                                            if info.isDebugMode > 0
                                                fprintf('lp%d_', j);
                                            end
                                        end
                                    end
                                    setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                    mappedList = [mappedList, i];
                                    numOfUpdates = numOfUpdates + 1;
                                    if info.isDebugMode > 0
                                        fprintf('lp%d=',i);
                                    end
                                else
                                    if isempty(find(childrenMapArr == -2, 1)) % There is no unmapped child
                                        if range(childrenMapArr) == 0 % all elements are same
                                            mappingOfBlocks(i) = childrenMapArr(1);
                                        else % all children are not mapped to same core.
                                            mappingOfBlocks(i) = 0;
                                        end
                                        setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                        mappedList = [mappedList, i];
                                        numOfUpdates = numOfUpdates + 1;
                                        if info.isDebugMode > 0
                                            fprintf('=');
                                        end
                                    else
                                        if range(childrenMapArr) == 0 % all children are unmapped
                                            relatedBlock = [];
                                            portsOfSrcBlk = get_param(newInfo.handles(i), 'PortConnectivity');
                                            if ~isempty(portsOfSrcBlk)
                                                for blockPortIndex = 1:length(portsOfSrcBlk) % for each port
                                                    if strcmpi(portsOfSrcBlk(blockPortIndex, 1).Type, 'ifaction') || ...
                                                            strcmpi(portsOfSrcBlk(blockPortIndex, 1).Type, 'trigger') || ...
                                                            strcmpi(portsOfSrcBlk(blockPortIndex, 1).Type, 'enable')
                                                        if mappingOfBlocks(getIndexFromHandle(portsOfSrcBlk(blockPortIndex, 1).SrcBlock, newInfo.handles)) > 0
                                                            relatedBlock = portsOfSrcBlk(blockPortIndex, 1).SrcBlock;
                                                            break;
                                                        else
                                                            relatedBlock = [relatedBlock, portsOfSrcBlk(blockPortIndex, 1).SrcBlock];
                                                        end
                                                    else
                                                        if ~isempty(portsOfSrcBlk(blockPortIndex, 1).SrcBlock)
                                                            relatedBlock = [relatedBlock, portsOfSrcBlk(blockPortIndex, 1).SrcBlock];
                                                        elseif ~isempty(portsOfSrcBlk(blockPortIndex, 1).DstBlock)
                                                            relatedBlock = [relatedBlock, portsOfSrcBlk(blockPortIndex, 1).DstBlock];
                                                        end
                                                    end
                                                end
                                                for k = relatedBlock
                                                    if mappingOfBlocks(getIndexFromHandle(k, newInfo.handles)) > 0
                                                        mappingOfBlocks(i) = mappingOfBlocks(getIndexFromHandle(k, newInfo.handles));
                                                        setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                                                        mappedList = [mappedList, i];
                                                        numOfUpdates = numOfUpdates + 1;
                                                        if info.isDebugMode > 0
                                                            fprintf('$');
                                                        end
                                                        for j = children
                                                            mappingOfBlocks(j) = mappingOfBlocks(i);
                                                            setMappingOfBlock(newInfo.blockList{j}, mappingOfBlocks(j));
                                                            mappedList = [mappedList, j];
                                                            numOfUpdates = numOfUpdates + 1;
                                                            if info.isDebugMode > 0
                                                                fprintf('#');
                                                            end
                                                        end
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            catch
                fprintf('Catch 1 - %d\n', i);
            end
        end
        unmappedList = setdiff(allBlocksList, mappedList);
    end
    unprocessedMappedList = setdiff(mappedList, mappedProcessedList);
    if isempty(unprocessedMappedList) && ~(isempty(unmappedList))
        if lastPass == 0 || (lastPass == 1 && numOfUpdates > 0)
            lastPass = 1;
            if info.isDebugMode > 0
                fprintf('\nlastPass\n');
            end
        else
            lastPass = 0;
        end
    else
        if lastPass == 1 && numOfUpdates == 0
            lastPass = 0;
        end
    end
end

fprintf('\nThere are %d unmapped blocks\n', numel(unmappedList));
for i = unmappedList
    blockType = newInfo.blockTypeList{i}{1};
    %blockType = get_param(newInfo.blockList{i}, 'BlockType');
    fprintf('%d - %s - %s unmapped\n', i, blockType, newInfo.blockList{i});
end

for i = 2:numOfAllblocks
    blockType = newInfo.blockTypeList{i};
    %blockType = get_param(newInfo.blockList{i}, 'BlockType');
    if strcmpi(blockType, 'Goto')
        gotoTag = cellstr(get_param(newInfo.blockList{i}, 'GotoTag'));
        gotoVisibility = get_param(newInfo.blockList{i}, 'TagVisibility');
        gotoParent = newInfo.parentHandles(i);
        fromMapArr = [];
        fromMapIndex = [];
        %tempStartArr = [];
        for j = 2:numOfAllblocks % searching corresponding From
            if strcmpi(newInfo.blockTypeList{j}, 'From') % fromIndex is a From
                fromTag = cellstr(get_param(newInfo.blockList{j}, 'GotoTag'));
                if strcmpi(gotoTag, fromTag) % This is a corresponsing "From"
                    fromParent = newInfo.parentHandles(j);
                    if strcmpi(gotoVisibility, 'global') == 1 || gotoParent == fromParent % if goto tag visibility is local, then only from tags in same subsystem receives data.
                        fromMapArr = [fromMapArr, mappingOfBlocks(j)];
                        fromMapIndex = [fromMapIndex, j];
                        %tempStartArr = [tempStartArr, startTimeOfBlocks(i)];
                    end
                end
            end
        end
        if ~isempty(fromMapArr)
            if isempty(find(fromMapArr < 0, 1)) % There is no unmapped from
                if range(fromMapArr) == 0 % all froms are on same core
                    if mappingOfBlocks(i) ~= fromMapArr(1) %Goto is not on same core as related Froms.. Take Goto to same core
                        mappingOfBlocks(i) = fromMapArr(1);
                        %sortedTempStartArr = sort(tempStartArr);
                        %startTimeOfBlocks(i) = sortedTempStartArr(1);
                        setMappingOfBlock(newInfo.blockList{i}, mappingOfBlocks(i));
                        if info.isDebugMode > 0
                            fprintf('Goto moved %d\n',i);
                        end
                    end
                else
                    parentOfGoto = get_param(newInfo.blockList{i}, 'Parent');
                    nameOfGoto = get_param(newInfo.blockList{i}, 'Name');
                    portsOfGoto = get_param(newInfo.blockList{i}, 'PortConnectivity');
                    gotoPosition = get_param(newInfo.blockList{i}, 'Position');
                    leftPos = gotoPosition(1);
                    topPos = gotoPosition(2);
                    rightPos = gotoPosition(3);
                    bottomPos = gotoPosition(4);
                    srcBlockName = get_param(portsOfGoto(1,1).SrcBlock, 'Name');
                    srcPortNo = portsOfGoto(1,1).SrcPort + 1;
                    
                    differentMappings = unique(fromMapArr);
                    for j = differentMappings
                        if j ~= mappingOfBlocks(i)
                            %Add a new Goto Block
                            nameOfNewGoto = sprintf('%s_core%d', nameOfGoto, j);
                            tagOfNewGoto = sprintf('%s_core%d', gotoTag{1}, j);
                            tempBottomPos = topPos - 5;
                            topPos = 2*topPos - bottomPos - 5;
                            bottomPos = tempBottomPos;
                            newBlockPosition = [leftPos, topPos, rightPos + 20, bottomPos];
                            newHandle = add_block('built-in/Goto', [parentOfGoto, sprintf('/%s', nameOfNewGoto)], 'Position', newBlockPosition, 'GotoTag', tagOfNewGoto, 'TagVisibility', gotoVisibility, 'ShowName', 'off');
                            setMappingOfBlock(newHandle, j);
                            add_line(parentOfGoto, sprintf('%s/%d', srcBlockName, srcPortNo), sprintf('%s/1', get_param(newHandle, 'Name')), 'autorouting', 'on');
                            
                            fromsMappedtoThis = find(fromMapArr == j);
                            for k = fromsMappedtoThis
                                %Change this From to From of newly added Goto
                                indexOfFrom = fromMapIndex(k);
                                set_param(newInfo.blockList{indexOfFrom}, 'GotoTag', tagOfNewGoto);
                            end
                        end
                    end
                end
            end
        end
    end
end
end

