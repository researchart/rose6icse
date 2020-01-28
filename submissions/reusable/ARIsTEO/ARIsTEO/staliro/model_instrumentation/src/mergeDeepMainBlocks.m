% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = mergeDeepMainBlocks( infoIn )
%mergeDeepMainBlocks For deep blocks (inside delay containing susbystem)
%find the correct mergeing which will not create a cycle and do the merge.

try
    info = infoIn;
    
    info.mergedBlockWCETs = info.wcet;
    mergedBlocksGraph = info.mainBlocksGraph;
    mergedBlockIndices = info.mainBlockIndices;
    mergeAvailable = 1;
    while mergeAvailable
        mergeAvailable = 0;
        for i = 1:length(mergedBlocksGraph);
            block = mergedBlockIndices{i}(1);
            if info.blockDepths(block) > info.desiredDepth
                blockParent = info.parentIndices(block);
                for j = find(mergedBlocksGraph(i, :))
                    dstBlock = mergedBlockIndices{j}(1);
                    dependentBlockParent = info.parentIndices(dstBlock);
                    if blockParent == dependentBlockParent
                        srcsOfDstBlock = find(mergedBlocksGraph(:, j));
                        srcsOfDstBlock = srcsOfDstBlock.';
                        inConsistencyDetected = 0;
                        for k = srcsOfDstBlock
                            kBlock = mergedBlockIndices{k}(1);
                            kBlockParent = info.parentIndices(kBlock);
                            if kBlockParent ~= blockParent %There is an input to destination block from another level. This merge can create cycle.
                                inConsistencyDetected = 1;
                                break;
                            end
                        end
                        if ~inConsistencyDetected
                            %merge j into i
                            mergeAvailable = 1;
                            mergedBlockIndices{i} = [mergedBlockIndices{i}, mergedBlockIndices{j}];
                            info.mergedBlockWCETs(i) = info.mergedBlockWCETs(i) + info.mergedBlockWCETs(j);
                            info.mergedBlockWCETs(j) = [];
                            dataItoJ = mergedBlocksGraph(i, j);
                            mergedBlocksGraph(i, :) = mergedBlocksGraph(i, :) + mergedBlocksGraph(j, :);
                            mergedBlocksGraph(:, i) = mergedBlocksGraph(:, i) + mergedBlocksGraph(:, j);
                            mergedBlocksGraph(i, i) = mergedBlocksGraph(i, i) - dataItoJ;
                            mergedBlocksGraph(j, :) = [];
                            mergedBlocksGraph(:, j) = [];
                            mergedBlockIndices(j) = [];
                            break;
                        end
                    end
                end
            end
            if mergeAvailable
                break;
            end
        end
    end
    info.mergedBlocksGraph = mergedBlocksGraph;
    info.mergedBlockIndices = mergedBlockIndices;
    info.numOfMergedBlocks = length(info.mergedBlocksGraph);
catch
    error('mergeDeepMainBlocks failed!');
end

end

