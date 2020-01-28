% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [A, b] = addRule6( info )
%addRule6 : A block cannot start execution before its predecessors
%finishes execution.
% Returns A and b for inequality rule Ax <= b
% Caller must append outputs of this function to global A and b

A = [];
b = [];
currentRow = 1;
for i = 1:numOfBlocks(info)
    si = getIndexS(i, info);
    for j = 1:numOfBlocks(info)
        if (i ~= j) && int64(info.connMatrix(i, j)) > 0
            sj = getIndexS(j, info);
            A(currentRow, 1:info.lengthOfX) = 0;
            A(currentRow, si) = 1;
            A(currentRow, sj) = -1;
            b(currentRow, 1) = double(0 - info.wcet(i));
            currentRow = currentRow + 1;
        end
    end
end
if info.debugMode > 0
    fprintf('Rule 6 added %d rules\n',currentRow - 1);
end
end
