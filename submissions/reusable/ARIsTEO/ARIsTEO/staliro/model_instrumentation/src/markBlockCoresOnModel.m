% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function markBlockCoresOnModel( info )
%markBlockCoresOnModel Mark each block with its core assignments

%First, mark the main blocks that we know the mapping.
try
    for i = 1:length(info.simpleBlockList)
        mappedCore = info.cpuAssignmentArrayForBlocks(i);
        userData = get_param(info.simpleBlockList{i}, 'UserData');
        userData.mapping = mappedCore;
        set_param(info.simpleBlockList{i}, 'UserData', userData);
    end
catch
    fprintf('ERROR: markBlockCoresOnModel %d\n', i);
end

%Now we will find mappings of other blocks which were discarded earlier.
newInfo.modelName = info.modelName;
newInfo.modelSearchDepth = info.modelSearchDepth;
try
    [newInfo.blockList, newInfo.wasModelOpenedAlready] = readModelBlockInformation(newInfo.modelName, newInfo.modelSearchDepth);
catch
    fprintf('ERROR: Model ''%s'' could not be loaded for marking blocks.\nBe sure to give model name as a parameter without file extension.\n', newInfo.modelName);
    return;
end

newInfo.handles = readBlockHandles(newInfo.blockList);
newInfo.parentHandles = readParentHandles(newInfo.blockList);

thereAreUnmappedBlocks = 1;
while thereAreUnmappedBlocks > 0
    thereAreUnmappedBlocks = 0;
    
    for i = 2:length(newInfo.blockList)
        try
            foundMapping = 0;
            userData = get_param(newInfo.blockList{i}, 'UserData');
            if ~isfield(userData, 'mapping')
                blockType = get_param(newInfo.blockList{i}, 'BlockType');
                if strcmpi(blockType,'Inport') || strcmpi(blockType,'From')
                    [ destinationsArr ] = findDestinationsOfBlock( i, newInfo );
                    for j = 1:numel(destinationsArr)
                        destUserData = get_param(newInfo.blockList{destinationsArr(j)}, 'UserData');
                        if isfield(destUserData, 'mapping')
                            if destUserData.mapping ~= 0
                                userData.mapping = destUserData.mapping;
                                set_param(newInfo.blockList{i}, 'UserData', userData);
                                foundMapping = 1;
                                break;
                            end
                        end
                    end
                    if foundMapping == 0
                        thereAreUnmappedBlocks = thereAreUnmappedBlocks + 1;
                    end
                elseif strcmpi(blockType,'Outport') || strcmpi(blockType,'Goto')
                    thereAreUnmappedBlocks = thereAreUnmappedBlocks + 1;
                    fprintf('%d - %s not mapped.\n', i, newInfo.blockList{i});
                elseif strcmpi(blockType, 'DataStoreMemory')
                    dataStoreName = get_param(newInfo.blockList{i}, 'DataStoreName');
                    for j = 2:length(newInfo.blockList)
                        blockType = get_param(newInfo.blockList{j}, 'BlockType');
                        if strcmpi(blockType, 'DataStoreRead') || strcmpi(blockType, 'DataStoreWrite')
                            if strcmpi(dataStoreName, get_param(newInfo.blockList{j}, 'DataStoreName'))
                                destUserData = get_param(newInfo.blockList{j}, 'UserData');
                                if isfield(destUserData, 'mapping')
                                    userData.mapping = destUserData.mapping;
                                    set_param(newInfo.blockList{i}, 'UserData', userData);
                                    foundMapping = 1;
                                    break;
                                end
                            end
                        end
                    end
                    if foundMapping == 0
                        thereAreUnmappedBlocks = thereAreUnmappedBlocks + 1;
                    end
                else
                    children = checkIfBlockIsAParent(newInfo.handles(i), newInfo.parentHandles);
                    if ~isempty(children) % Block is parent of some other blocks
                        childrenMapArr = [];
                        % check if all subblocks are on same core or not
                        for j = children
                            blockType = get_param(newInfo.blockList{j}, 'BlockType');
                            if ~(strcmpi(blockType,'TriggerPort') || strcmpi(blockType,'ActionPort')...
							|| strcmpi(blockType,'EnablePort') || strcmpi(blockType,'WhileIterator'))
                                childUserData = get_param(newInfo.blockList{j}, 'UserData');
                                if isfield(childUserData, 'mapping')
                                    childrenMapArr = [childrenMapArr, childUserData.mapping];
                                else % There is a child which is not mapped.
                                    childrenMapArr = [childrenMapArr, -1];
                                    break;
                                end
                            end
                        end
                        if ~isempty(find(childrenMapArr == -1, 1)) % There is at least one unmapped child
                            thereAreUnmappedBlocks = thereAreUnmappedBlocks + 1;
                            fprintf('%d - %s not mapped.\n', i, newInfo.blockList{i});
                        elseif range(childrenMapArr) == 0 % all elements are same
                            userData.mapping = childrenMapArr(1);
                            set_param(newInfo.blockList{i}, 'UserData', userData);
                        else % all children are not mapped to same core.
                            userData.mapping = 0;
                            set_param(newInfo.blockList{i}, 'UserData', userData);
                        end
                    end
                end
            else
                foundMapping = 1;
                if userData.mapping ~= 0
                    % If block is mapped, all of its children will be mapped to same core
                    children = checkIfBlockIsAParent(newInfo.handles(i), newInfo.parentHandles);
                    if ~isempty(children)
                        for j = children
                            childUserData = get_param(newInfo.blockList{j}, 'UserData');
                            if ~isfield(childUserData, 'mapping')
                                childUserData.mapping = userData.mapping;
                                set_param(newInfo.blockList{j}, 'UserData', childUserData);
                            end
                        end
                    end
                    
                    % If block is mapped, map all unmapped destinations of type 'Outport' or 'Goto' to same core.
                    [ destinationsArr ] = findDestinationsOfBlock( i, newInfo );
                    for j = 1:numel(destinationsArr)
                        destUserData = get_param(newInfo.blockList{destinationsArr(j)}, 'UserData');
                        if ~isfield(destUserData, 'mapping')
                            blockType = get_param(newInfo.blockList{destinationsArr(j)}, 'BlockType');
                            if strcmpi(blockType,'Outport') || strcmpi(blockType,'Goto')
                                destUserData.mapping = userData.mapping;
                                set_param(newInfo.blockList{destinationsArr(j)}, 'UserData', destUserData);
                            end
                        end
                    end
                end
            end
        catch
            thereAreUnmappedBlocks = thereAreUnmappedBlocks + 1;
        end
    end
    fprintf('There are %d unmapped blocks.\n', thereAreUnmappedBlocks);
end

%Mark trigger/action ports
for i = 2:length(newInfo.blockList)
    blockType = get_param(newInfo.blockList{i}, 'BlockType');
    if strcmpi(blockType,'TriggerPort') || strcmpi(blockType,'ActionPort') || strcmpi(blockType,'EnablePort') || strcmpi(blockType,'WhileIterator')
        try
            userData = get_param(newInfo.parentHandles(i), 'UserData');
            if isfield(userData, 'mapping')
                newUserData = get_param(newInfo.blockList{i}, 'UserData');
                newUserData.mapping = userData.mapping;
                set_param(newInfo.blockList{i}, 'UserData', newUserData);
            end
        catch
        end
    end
end

for i = 2:length(newInfo.blockList)
    try
        userData = get_param(newInfo.blockList{i}, 'UserData');
        if ~isfield(userData, 'mapping')
            blockType = get_param(newInfo.blockList{i}, 'BlockType');
            fprintf('ERROR: Block %d - %s has type %s and could not find mapping to any core!!\n', i, newInfo.blockList{i}, blockType);
        else
            [~, colorStr] = getMappingColor(userData.mapping);
            set_param(newInfo.blockList{i}, 'ForegroundColor', colorStr);
        end
    catch
    end
end

end

