% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule1( info )
%addRule1 : Every block must be assigned to a single core.
% Creates Aeq and beq matrices for rule 1
% Caller must append outputs of this function to global Aeq and beq

A = [];
b = [];
currentRow = 1;
for i = 1:numOfBlocks(info)
    A(currentRow, 1:info.lengthOfX) = 0;
    if info.B(i, 1) == -1 % undecided
        for p = 1:info.numOfCores
            bip = getIndexB(i, p, info);
            A(currentRow, bip) = 1;
        end
        b(currentRow, 1) = 1;
        currentRow = currentRow + 1;
    else
        for p = 1:info.numOfCores
            if info.B(i, p) == 1
                bip = getIndexB(i, p, info);
                A(currentRow, bip) = 1;
            end
        end
        b(currentRow, 1) = 1;
        currentRow = currentRow + 1;
        
        for p = 1:info.numOfCores
            if info.B(i, p) == 0
                bip = getIndexB(i, p, info);
                A(currentRow, bip) = 1;
            end
        end
        b(currentRow, 1) = 0;
        currentRow = currentRow + 1;
    end
end
if info.debugMode > 0
    fprintf('Rule 1 added %d rules\n', currentRow - 1);
end
end

