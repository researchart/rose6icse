% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ mergedBlockId ] = findCorrespondingMergedBlock(blockId, info)
%findCorrespondingMergedBlock Searches inside info.mergedBlockIndices for 
%the given blockId.

try
    mergedBlockId = -1;
    for i = 1:info.numOfMergedBlocks
        if ~isempty(find(info.mergedBlockIndices{i} == blockId, 1))
            mergedBlockId = i;
        end
    end
catch
    error('ERROR: findCorrespondingMergedBlock failed!');
end

end

