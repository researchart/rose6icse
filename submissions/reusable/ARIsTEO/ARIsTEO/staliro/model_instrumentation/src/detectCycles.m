% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ cycleCount, pathsList, cycleBlocks ] = detectCycles( connMatrix )
%detectCycles Detects any cycles in the given adjacency matrix.
% Each entry of returned pathslist contains sources and destinations of paths at each length

try
    cycleCount = 0;
    accessMatrix = connMatrix;
    stepCount = 1;
    cycleBlocks = [];
    numOfNodes = length(connMatrix);
    pathsList = cell(numOfNodes, 0);
    
    %clear cycles
    while ~isempty(find(accessMatrix, 1)) && stepCount < numOfNodes
        pathsList{stepCount} = accessMatrix;
        for m = 1:length(connMatrix)
            if accessMatrix(m, m) > 0 && isempty(find(cycleBlocks == m, 1))
                fprintf('! Detected cycle from %d to itself in %d steps\n', m, stepCount);
                cycleCount = cycleCount + 1;
                cycleBlocks = [cycleBlocks, m];
                break;
            end
        end
        stepCount = stepCount + 1;
        accessMatrix = connMatrix^stepCount;
    end
    if stepCount < numOfNodes
        pathsList(stepCount + 1:end) = [];
    end
catch
    error('ERROR: detectCycles failed!');
end

end

