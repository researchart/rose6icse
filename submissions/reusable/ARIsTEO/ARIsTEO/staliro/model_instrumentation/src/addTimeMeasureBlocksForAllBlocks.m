% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ listOfMeasureBlocks ] = addTimeMeasureBlocksForAllBlocks( info )
%addTimeMeasureBlocksForAllBlocks add Time Measure Blocks For All Blocks in
%merged list

blockNo = 0;
listOfMeasureBlocks = [];
try
    for i = 1:info.numOfMergedBlocks
        for j = info.mergedBlockIndices{i}
            try
                if addTimeMeasureBlocks(info, j, blockNo)
                    blockNo = blockNo + 1;
                    listOfMeasureBlocks(blockNo) = j;
                end
            catch
                fprintf('WARNING! Could not add time measure blocks for block %d\n', j)
            end
        end
    end
catch
    error('ERROR: addTimeMeasureBlocksForAllBlocks failed!');
end
end

