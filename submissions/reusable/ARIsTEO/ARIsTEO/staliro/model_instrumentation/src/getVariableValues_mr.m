% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function name = getVariableValues_mr(info)

n = info.numOfMainBlocks;
name = cell(1, info.lengthOfX);
for i = 1:info.lengthOfX
    if i == info.optimIndex
        name{i} = 'f';
    elseif i >= info.startOfS
        blockId = info.blocksInHyperPeriod{i-(info.startOfS-1)}.block;
        copyCount = info.blocksInHyperPeriod{i-(info.startOfS-1)}.copyCount;
        sampleTimeId = info.blocksInHyperPeriod{i-(info.startOfS-1)}.sampleTimeId;
        name{i} = sprintf('s(%d,%d, %d)',blockId,copyCount, sampleTimeId);
    elseif i >= info.startOfP
        index = i-(info.startOfP-1);
        for j = 1:numel(info.blocksInHyperPeriod)
            preempTo = find(info.preemptionGraph(j,:) == index, 1);
            if ~isempty(preempTo)
                blockId = info.blocksInHyperPeriod{j}.block;
                copyCount = info.blocksInHyperPeriod{j}.copyCount;
                name{i} = sprintf('p(%d_%d,%d)',blockId,copyCount,preempTo);
            end
        end
        name{i} = sprintf('(%g)', info.x.x(i));
    elseif i >= info.startOfD
        index = i-(info.startOfD-1);
        for j = 1:info.numOfMainBlocks
            indTo = find(info.independencyGraph(j,:) == index, 1);
            if ~isempty(indTo)
                name{i} = sprintf('d(%d,%d)',j,indTo);
            end
        end
        name{i} = sprintf('(%g)', info.x.x(i));
    else
        for b = 1:n
            startOfNextBlock = info.startOfB + (b * info.numOfCores);
            if i < startOfNextBlock
                p = info.numOfCores - ((startOfNextBlock - i) - 1);
                name{i} = sprintf('b(%d,%d)', b, p);
                if getIndexB(b, p, info) ~= i
                    fprintf('index B of %d,%d is not %d\n', b, p, i);
                end
                name{i} = sprintf('(%g)', info.x.x(i));
                break;
            end
        end
    end
end
end

