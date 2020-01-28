% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = findDataTimings( infoIn )
%findDataTimings Finds the time for each port when the data at this port
%will be ready.

try
    info = infoIn;
    portDepMatrix = findDependencies(info.portsGraph);
    
    for i = 1:numel(info.ports)
        info.ports(i).dataReadyTime = -1;
    end
    
    for i = 1:numel(info.ports)
        if isempty(find(info.portsGraph(:, i), 1)) %No incoming connection -> it is a source
            allNodes = [i, find(portDepMatrix(i, :))];
            for n = allNodes
                srcBlock = info.ports(n).block;
                srcMergedBlock = findCorrespondingMergedBlock(srcBlock, info); % this is the merged block before milp formulation
                if srcMergedBlock > 0
                    mergedListId = findInMergedList(srcMergedBlock, info.solverInfo.mergedList); %this is the second level merge done by milp formulation
                    if mergedListId > 0
                        dataReadyTime = info.x.x(getIndexS(mergedListId, info.solverInfo)) + info.solverInfo.wcet(mergedListId);

                        for j = allNodes
                            info.ports(j).dataReadyTime = dataReadyTime;
                        end
                    end
                    break;
                end
            end
        end
    end
catch
    error('ERROR: findDataTimings failed!');
end

end

