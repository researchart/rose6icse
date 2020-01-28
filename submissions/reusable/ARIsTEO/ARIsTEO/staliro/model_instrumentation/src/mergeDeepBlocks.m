% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = mergeDeepBlocks( infoIn )
%mergeDeepBlocks Merge deeper blocks than desired model depth

try
    info = infoIn;
    mergeGroup = cell(0, 0);
    numOfGroups = 0;
    
    for i = 2:info.numOfBlocks
        children = [];
        blockDepth = info.blockDepths(i);
        if blockDepth == info.desiredDepth && strcmpi(info.blockTypeList{i}, 'Subsystem')
            %Search children of this block in main blocks
            for j = 1:info.numOfMainBlocks
                if numel(info.mainBlockIndices{j}) == 1
                    childIndex = info.mainBlockIndices{j}(1);
                    if ~isempty(find(info.ancestorsList{childIndex} == i, 1))
                        children = [children, j];
                    end
                end
            end
        end
        if ~isempty(children)
            subConnMatrix = info.mainBlocksConnMatrix(children, children);
            sparseSubConnMatrix = sparse(subConnMatrix);
            [S, C] = graphconncomp(sparseSubConnMatrix, 'Directed', 1, 'Weak', 1);
            group = cell(S, 0);
            for j = 1:S
                group{j} = [];
            end
            for j = 1:numel(C)
                group{C(j)} = [group{C(j)}, children(j)]; 
            end
            for j = 1:S
                if numel(group{j}) > 1
                    numOfGroups = numOfGroups + 1;
                    mergeGroup{numOfGroups} = group{j};
                end
            end
            fprintf('Merge %d blocks\n', numel(C));
        end
    end
    mergedGraph = info.mainBlocksGraph;
    blocksToDelete = [];
    for i = 1:numOfGroups
        % merge ...
        others = setdiff(1:info.numOfMainBlocks, mergeGroup{i});
        inConn = zeros(info.numOfMainBlocks, 1);
        outConn = zeros(1, info.numOfMainBlocks);
        for j = others
            mergedGraph(j, mergeGroup{i}(1)) = sum(info.mainBlocksGraph(j, mergeGroup{i}));
            mergedGraph(mergeGroup{i}(1), j) = sum(info.mainBlocksGraph(mergeGroup{i}, j));
        end
        blocksToDelete = [blocksToDelete, mergeGroup{i}(2:end)];
        
        mergedGraphLogical = logical(mergedGraph); %All edge costs are converted to 1
        if ~graphisdag(sparse(mergedGraphLogical))
            fprintf('Group %d created cycle in merge.\n', i);
        end
        info.mainBlockIndices{mergeGroup{i}(1)} = cell2mat(info.mainBlockIndices(mergeGroup{i}));
        info.mainBlockWCETs(mergeGroup{i}(1)) = sum(info.mainBlockWCETs(mergeGroup{i}));
    end
    mergedGraph(blocksToDelete, :) = [];
    mergedGraph(:, blocksToDelete) = [];
    
    info.mainBlockIndices(blocksToDelete) = [];
    info.mainBlocksGraph = mergedGraph;
    info.numOfMainBlocks = length(mergedGraph);
    info.mainBlockWCETs(blocksToDelete) = [];
catch
    error('ERROR: mergeDeepBlocks failed!');
end

end

