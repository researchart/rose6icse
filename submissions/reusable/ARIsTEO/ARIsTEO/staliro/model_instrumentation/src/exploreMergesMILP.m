% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [info, merged] = exploreMergesMILP(infoIn, extraFeatures)
info = infoIn;

if nargin < 2
    extraFeatures = 0;
end
merged = 0;

for i = 1:length(info.connMatrix)
    if merged > 0
        break;
    end
    childrenCount = 0;
    for j = 1:length(info.connMatrix)
        if int64(info.connMatrix(i,j)) > 0
            childrenCount = childrenCount + 1;
            if childrenCount > 1;
                break; %does not have single child
            end
            singleChild = j;
        end
    end
    
    if childrenCount == 1
        parentCount = 0;
        for j = 1:length(info.connMatrix)
            if int64(info.connMatrix(j,singleChild)) > 0
                parentCount = parentCount + 1;
                if parentCount > 1;
                    break; %does not have single parent
                end
            end
        end
        if parentCount == 1
            if info.delayConn(i, j) + info.delayConn(j, i) == 0 %don't merge delay blocks we will split them
                if info.debugMode > 0
                    fprintf('%d - %d is single parent-child.. merge %d into %d\n', i, singleChild, singleChild, i);
                end
                [info, merged] = mergeBlocksMILP(singleChild, i, singleChild, 1, info, extraFeatures);
            end
        elseif info.wcet(i) < info.wcet(singleChild)/10
            if info.delayConn(i, j) + info.delayConn(j, i) == 0 %don't merge delay blocks we will split them
                if info.debugMode > 0
                    fprintf('%d is trivial and %d is single child.. merge %d into %d\n', i, singleChild, i, singleChild);
                end
                [info, merged] = mergeBlocksMILP(i, singleChild, singleChild, 1, info, extraFeatures);
            end
        end
    end
    if merged == 0
        parentCount = 0;
        for j = 1:length(info.connMatrix)
            if int64(info.connMatrix(j, i)) > 0
                parentCount = parentCount + 1;
                if parentCount > 1;
                    break; %does not have single parent
                end
                singleParent = j;
            end
        end
        if parentCount == 1
            if info.wcet(i) < info.wcet(singleParent)/10
                if info.delayConn(i, j) + info.delayConn(j, i) == 0 %don't merge delay blocks we will split them
                    if info.debugMode > 0
                        fprintf('%d is single parent of %d (trivial).. merge %d into %d\n',singleParent,i,i,singleParent);
                    end
                    [info, merged] = mergeBlocksMILP(i, singleParent, i, 1, info, extraFeatures);
                end
            end
        end
    end
end
end

