% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [connMatrix, cyclesRemoved] = removeCycles(connMatrixIn, isDebugMode, txCostMatrix, rxCostMatrix)

cycle = 1;
cyclesRemoved = 0;
connMatrix = connMatrixIn;
while cycle == 1
    accessMatrix = connMatrix;
    stepCount = 1;
    cycle = 0;
    
    %clear cycles
    while ~isempty(find(accessMatrix, 1)) && stepCount < length(connMatrix)
        for m = 1:length(connMatrix)
            if accessMatrix(m, m) > 0
                if isDebugMode > 0
                    fprintf('! Detected cycle from %d to itself in %d steps\n', m, stepCount);
                end
                cycle = 1;
                if nargin < 3
                    connMatrix = clearCycle(m, stepCount, connMatrix, isDebugMode);
                else
                    connMatrix = clearCycle(m, stepCount, connMatrix, isDebugMode, txCostMatrix, rxCostMatrix);
                end
                cyclesRemoved = cyclesRemoved + 1;
                break;
            end
            if cycle == 1
                break;
            end
        end
        if cycle == 1
            break;
        end
        stepCount = stepCount + 1;
        accessMatrix = connMatrix^stepCount;
    end
end
end
