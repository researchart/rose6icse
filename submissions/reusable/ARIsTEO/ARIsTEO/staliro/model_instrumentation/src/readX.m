% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function readX(x, giveBlockNames, info)

if info.lengthOfX == length(x)
    if info.isMultiRate
        for i = 1:numel(info.blocksInHyperPeriod)
            blockId = info.blocksInHyperPeriod{i}.block;
            coreMapped = 0;
            copyCount = info.blocksInHyperPeriod{i}.copyCount;
            executionStartTime = info.solverOutputs.x(info.startOfS+i-1);
            executionFinishTime = executionStartTime + info.wcet(blockId);
            for p = 1:info.numOfCores
                if int64(x(getIndexB(blockId, p, info))) == 1
                    coreMapped = p;
                end
            end
            mainBlockId = info.mainBlocks(blockId);
            if giveBlockNames == 1
                blockName = info.blockList{mainBlockId};
            else
                blockName = ' ';
            end
            fprintf('Blk %d,%d, core: %d, time: %g - %g, (main:%d): %s\n', ...
                blockId, copyCount, coreMapped, executionStartTime, executionFinishTime, mainBlockId, blockName);
        end
    else
        for p = 1:info.numOfCores
            for i = 1:numOfBlocks(info)
                if int64(x(getIndexB(i, p, info))) == 1
                    if giveBlockNames == 1
                        fprintf('Block %d: %s is mapped to core %d, will execute at %g\n', i, info.blockList{i}, p, x(getIndexS(i, info)));
                    else
                        fprintf('Block %d is mapped to core %d, will execute at %g\n', i, p, x(getIndexS(i, info)));
                    end
                end
            end
        end
    end
else
    fprintf('ERROR in readX: NOT compatible x.. Size (%d) is different than expected(%d)!\n', length(x), info.lengthOfX);
end
end
