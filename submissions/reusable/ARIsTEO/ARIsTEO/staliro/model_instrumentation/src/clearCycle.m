% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function connMatrix = clearCycle(block, stepCount, connMatrixIn, isDebugMode, txCostMatrix, rxCostMatrix)

connMatrix = connMatrixIn;
if stepCount == 1
    connMatrix(block, block) = 0;
    if isDebugMode > 0
        fprintf('.. Deleted connection from %d to itself\n', block);
    end
else
    firstPart = connMatrix^(stepCount - 1);
    for i = 1:length(connMatrix)
        if connMatrix(i, block) > 0 && firstPart(block, i) > 0
            connMatrix(i, block) = 0;
            if nargin > 4
                txCostMatrix(i, block) = 0;
            end
            if nargin > 5
                rxCostMatrix(i, block) = 0;
            end
            if isDebugMode > 0
                fprintf('.. Deleted connection from %d to %d\n', i, block);
            end
        end
    end
end
end
