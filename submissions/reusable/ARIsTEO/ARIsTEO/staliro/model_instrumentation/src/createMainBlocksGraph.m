% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = createMainBlocksGraph( infoIn )
%createMainBlocksGraph Create conn matrix for main blocks using the
%mainDataDepGraph.

try
    info = infoIn;
    
    mainBlocksGraph = zeros(info.numOfMainBlocks);
    
    for i = 1:numel(info.mainPorts)
        block = info.mainPorts(i).block;
        mainBlock = findCorrespondingMainBlock(block, info);
        dataSize = info.mainPorts(i).dataSize;
        if isempty(dataSize) %this is the case for action / case/ if / else blocks
            dataSize = 1;
        end
        dsts = find(info.mainDataDepGraph(i, :));
        for j = dsts
            dstBlock = info.mainPorts(j).block;
            %in mainDataDepGraph input ports of a block are connected to
            %output ports of same block
            if (block ~= dstBlock) && (isempty(find(strcmpi(info.blockTypeList{dstBlock},...
                    {'UnitDelay', 'Delay', 'ZeroOrderHold', 'Memory'}), 1)))
                %Connect only if destionation is not delay introducing
                %block
                dstMainBlock = findCorrespondingMainBlock(dstBlock, info);
                mainBlocksGraph(mainBlock, dstMainBlock) = dataSize;
            end
        end
    end
    info.mainBlocksGraph = mainBlocksGraph;
catch
    error('createMainBlocksGraph failed!');
end


end

