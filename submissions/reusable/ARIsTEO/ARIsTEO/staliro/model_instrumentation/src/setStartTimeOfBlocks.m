% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function newInfo = setStartTimeOfBlocks( info )
%setStartTimeOfBlocks Set start time of ICComm blocks
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
connMatrix = generateConnectionsMatrix( newInfo );

numOfAllblocks = length(newInfo.blockList);

newInfo.startTimeOfBlocks = -1 * ones(1, numOfAllblocks);
newInfo.wcetOfBlocks = zeros(1, numOfAllblocks);

try
    for i = 2:length(info.simpleBlockList)
        handle = get_param(info.simpleBlockList{i}, 'Handle');
        index = getIndexFromHandle(handle, newInfo.handles);
        newInfo.startTimeOfBlocks(index) = info.executionTimesForBlocks(i);
        newInfo.wcetOfBlocks(index) = info.orgSimpleWcetArr(i);
    end
catch
    fprintf('ERROR: setStartTimeOfBlocks %d\n', i);
end

numOfUpdates = 1;
while numOfUpdates > 0
    try
    numOfUpdates = 0;
    for i = 2:numOfAllblocks
        if newInfo.startTimeOfBlocks(i) >= 0
            for j = find(connMatrix(i, :) > 0)
                if newInfo.startTimeOfBlocks(j) < 0
                    children = checkIfBlockIsAParent(newInfo.handles(j), newInfo.parentHandles);
                    if isempty(children)
                        newInfo.startTimeOfBlocks(j) = newInfo.startTimeOfBlocks(i) + newInfo.wcetOfBlocks(i);
                        if strcmpi(newInfo.blockTypeList{j}, 'Goto')
                            gotoTag = cellstr(get_param(newInfo.blockList{j}, 'GotoTag'));
                            gotoVisibility = get_param(newInfo.blockList{j}, 'TagVisibility');
                            gotoParent = newInfo.parentHandles(j);
                            %startTimeOfDests = [];
                            for k = 2:numOfAllblocks % searching corresponding From
                                if strcmpi(newInfo.blockTypeList{k}, 'From') % fromIndex is a From
                                    fromTag = cellstr(get_param(newInfo.blockList{k}, 'GotoTag'));
                                    if strcmpi(gotoTag, fromTag) % This is a corresponsing "From"
                                        fromParent = newInfo.parentHandles(k);
                                        if strcmpi(gotoVisibility, 'global') == 1 || gotoParent == fromParent % if goto tag visibility is local, then only 'From' tags in same subsystem receives data.
                                            newInfo.startTimeOfBlocks(k) = newInfo.startTimeOfBlocks(j);
                                        end
                                    end
                                end
                            end
                        end
                        numOfUpdates = numOfUpdates + 1;
                    end
                end
            end
            for j = (find(connMatrix(:, i) > 0)).'
                if newInfo.startTimeOfBlocks(j) < 0
                    children = checkIfBlockIsAParent(newInfo.handles(j), newInfo.parentHandles);
                    if isempty(children)
                        newInfo.startTimeOfBlocks(j) = newInfo.startTimeOfBlocks(i);
                        if strcmpi(newInfo.blockTypeList{j}, 'From')
                            gotoTag = cellstr(get_param(newInfo.blockList{j}, 'GotoTag'));
                            
                            gotoParent = newInfo.parentHandles(j);
                            %startTimeOfDests = [];
                            for k = 2:numOfAllblocks % searching corresponding From
                                if strcmpi(newInfo.blockTypeList{k}, 'Goto') % fromIndex is a From
                                    fromTag = cellstr(get_param(newInfo.blockList{k}, 'GotoTag'));
                                    gotoVisibility = get_param(newInfo.blockList{k}, 'TagVisibility');
                                    if strcmpi(gotoTag, fromTag) % This is a corresponsing "From"
                                        fromParent = newInfo.parentHandles(k);
                                        if strcmpi(gotoVisibility, 'global') == 1 || gotoParent == fromParent % if goto tag visibility is local, then only 'From' tags in same subsystem receives data.
                                            newInfo.startTimeOfBlocks(k) = newInfo.startTimeOfBlocks(j);
                                        end
                                    end
                                end
                            end
                        end
                        numOfUpdates = numOfUpdates + 1;
                    end
                end
            end
        end
    end
    catch
        fprintf('!\n');
    end
end

numOfUpdates = 1;
while numOfUpdates > 0
    numOfUpdates = 0;
    
    for i = 2:numOfAllblocks
        try
            if newInfo.startTimeOfBlocks(i) < 0
                blockName = get_param(newInfo.handles(i), 'Name');
                if length(blockName) > 8
                    if strcmpi(blockName(1:8), 'ICSender')
                        portsOfBlock = get_param(newInfo.handles(i), 'PortConnectivity');
                        execTime = findExecutionTimeOfBlock(newInfo, getIndexFromHandle(portsOfBlock(1).SrcBlock(1), newInfo.handles), portsOfBlock(1).SrcPort(1));
                        sortedExecTime = sort(execTime, 'descend');
                        newInfo.startTimeOfBlocks(i) = sortedExecTime(1);
                        bufferID = get_param(newInfo.handles(i), 'icSendBufID');
                        for j = 2:numOfAllblocks
                            blockName = get_param(newInfo.handles(j), 'Name');
                            if length(blockName) > 10
                                if strcmpi(blockName(1:10), 'ICReceiver')
                                    rxBufferID = get_param(newInfo.handles(j), 'icRcvBufID');
                                    if strcmpi(bufferID, rxBufferID)
                                        newInfo.startTimeOfBlocks(j) = newInfo.startTimeOfBlocks(i);
                                        numOfUpdates = numOfUpdates + 1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        catch
            fprintf('!!! %s \n', blockName);
        end
    end
end

end

