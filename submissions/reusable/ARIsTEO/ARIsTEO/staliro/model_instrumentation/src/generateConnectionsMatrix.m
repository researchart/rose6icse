% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ connMatrix ] = generateConnectionsMatrix( info )
%generateConnectionsMatrix Generates connection matrix from immediate conenctions only.

connMatrix = zeros(length(info.blockList));
for i = 2:length(info.blockList)
    portsOfBlock = get_param(info.blockList{i}, 'PortConnectivity');
    for blockPortIndex = 1:length(portsOfBlock) % for each port
        if ~isempty(portsOfBlock(blockPortIndex,1).DstBlock) % This is an output port
            for blockDestination = 1:length(portsOfBlock(blockPortIndex,1).DstBlock) % for each destination
                destHandle = portsOfBlock(blockPortIndex,1).DstBlock(blockDestination);
                connMatrix(i, getIndexFromHandle(destHandle, info.handles)) = 1;
            end
        end
    end
end
end
