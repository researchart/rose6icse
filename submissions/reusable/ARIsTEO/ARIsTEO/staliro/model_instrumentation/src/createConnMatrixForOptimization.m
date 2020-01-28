% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = createConnMatrixForOptimization( infoIn )
%createConnMatrixForOptimization Create a connection matrix for main blocks
%using the ports connections information.

try
    info = infoIn;
    
    info.mainBlocksConnMatrix = zeros(info.numOfMainBlocks);
    portDepMatrix = findDependencies(info.portsGraph);
    for i = 1:numel(info.ports)
        if info.ports(i).type == 0 %output
            srcBlock = info.ports(i).block;
            srcMainBlock = findCorrespondingMainBlock(srcBlock, info);
            if srcMainBlock > 0 % else there is no main block for this, so no need to add
                destinationPorts = find(portDepMatrix(i, :));
                for j = destinationPorts
                    dstBlock = info.ports(j).block;
                    dstMainBlock = findCorrespondingMainBlock(dstBlock, info);
                    if dstMainBlock > 0 && dstMainBlock ~= srcMainBlock
                        info.mainBlocksConnMatrix(srcMainBlock, dstMainBlock) = info.ports(i).dataSize;
                    end
                end
            end
        end
    end
catch
    error('ERROR: createConnMatrixForOptimization failed!');
end

end

