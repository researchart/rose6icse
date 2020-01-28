% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function delayConns = getDelayConnections(blockIndex, info, direction)
%direction = 1: incoming connections from delay introducing blocks
%direction = 0: outgoing connections to delay introducing blocks.

delayConns = [];
if direction == 1 %incoming
    conns = find(info.portsGraph(:, blockIndex));
	conns = conns.'; %transpose for getting a 1 by n matrix
else %outgoing
    conns = find(info.portsGraph(blockIndex, :));
end
for j = conns
    connIndex = info.ports(j).block;
    if isDelayIntroducing(info.blockTypeList{connIndex});
        delayConns = [delayConns, j];
    end
end
end