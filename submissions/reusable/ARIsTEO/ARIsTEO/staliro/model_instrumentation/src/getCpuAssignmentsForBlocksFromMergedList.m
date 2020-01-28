% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = getCpuAssignmentsForBlocksFromMergedList( infoIn )
%getCpuAssignmentsForBlocksFromMergedList Reads the cpu assignments of merged 
% blocks and transfers the assignments to the blocks.

info = infoIn;

info.cpuAssignmentArrayForBlocks = zeros(info.numOfBlocks, 1);
for k = 1:length(info.solverInfo.mergedList)
    for i = info.solverInfo.mergedList{k}
       for j = info.mergedBlockIndices{i}
           info.cpuAssignmentArrayForBlocks(j) = info.cpuAssignmentArray(k);
           info.executionTimesForBlocks(j) = info.x.x(getIndexS(k, info.solverInfo));
       end
    end
end

% If any of the ancestors is mapped then copy that mapping to this block.
for i = 1:info.numOfBlocks
    if info.cpuAssignmentArrayForBlocks(i) == 0 %not mapped
        for j = info.ancestorsList{i}
            if j > 0
                if info.cpuAssignmentArrayForBlocks(j) > 0 %one of the ancestors is mapped
                    info.cpuAssignmentArrayForBlocks(i) = info.cpuAssignmentArrayForBlocks(j);
                    info.executionTimesForBlocks(i) = info.executionTimesForBlocks(j);
                end
            end
        end
    end
end

for i = 1:numel(info.ports)
   if info.cpuAssignmentArrayForBlocks(info.ports(i).block) > 0
       info.ports(i).mapping = info.cpuAssignmentArrayForBlocks(info.ports(i).block);
   end
end
       
end

