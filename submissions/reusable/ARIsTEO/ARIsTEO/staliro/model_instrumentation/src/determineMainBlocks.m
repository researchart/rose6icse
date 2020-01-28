% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = determineMainBlocks( infoIn )
%determineMainBlocks Decide which blocks will be main blocks.

try
    info = infoIn;
    
    blocksToDecide = 2:info.numOfBlocks;
    blocksToDiscard = 1; %Automatically discard the model container.
    mainBlocks = [];
    currentBlockDepth = 1;
    while ~isempty(blocksToDecide)
        processedBlocks = [];
        for i = blocksToDecide;
            if info.blockDepths(i) == currentBlockDepth
                processedBlocks = i;
                if ~isempty(find(strcmpi(info.blockTypeList{i},...
                    {'Goto', 'From', 'DataStoreMemory', 'Scope'}), 1))
                    blocksToDiscard = [blocksToDiscard, i];
                elseif ~isempty(find(strcmpi(info.blockTypeList{i},...
                    {'Inport', 'Outport'}), 1))
                    if currentBlockDepth > 1
                        blocksToDiscard = [blocksToDiscard, i];
                    else
                        mainBlocks = [mainBlocks, i];
                    end
                elseif ~isempty(find(strcmpi(info.blockTypeList{i},...
                    {'Subsystem'}), 1))
                    if ~isempty(find(info.blockSpecialties{i} == 1, 1))
                        blockContainsDelay = 1;
                    else
                        blockContainsDelay = 0;
                    end
                    blockIsNonVirtual = ~isempty(find(info.nonVirtualSubsystems == i, 1));
%                    if currentBlockDepth < info.desiredDepth || (blockContainsDelay && ~blockIsNonVirtual)
                    if currentBlockDepth < info.desiredDepth || (blockContainsDelay)% && ~blockIsNonVirtual)
                        blocksToDiscard = [blocksToDiscard, i];
                    elseif (currentBlockDepth >= info.desiredDepth) && (~blockContainsDelay)% || blockIsNonVirtual)
                        % We will not discard this subsystem but discard
                        % everything inside.
                        mainBlocks = [mainBlocks, i];
                        for j = blocksToDecide
                            if ~isempty(find(info.ancestorsList{j} == i, 1))
                                blocksToDiscard = [blocksToDiscard, j];
                                processedBlocks = [processedBlocks, j];
                            end
                        end
                    end
                else
                    mainBlocks = [mainBlocks, i];
                end
                break;
            end
        end
        blocksToDecide = setdiff(blocksToDecide, processedBlocks);
        if isempty(processedBlocks)
            currentBlockDepth = currentBlockDepth + 1;
        end
    end
    info.mainBlocks = mainBlocks;
    info.blocksToDiscard = blocksToDiscard;
    info.numOfMainBlocks = numel(mainBlocks);
    for i = 1:numel(mainBlocks);
        info.mainBlockIndices{i} = mainBlocks(i);
    end
catch
    error('determineMainBlocks failed!');
end

end

