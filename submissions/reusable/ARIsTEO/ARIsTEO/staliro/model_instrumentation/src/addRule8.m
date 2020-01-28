% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [A, b] = addRule8( info )
%addRule8 Optimization parameter is an upper bound for start time + wcet of leafs
%   Returns A and b for inequality rule Ax <= b

A = [];
b = [];
currentRow = 1;
for i = 1:numOfBlocks(info)
    if isBlockLeaf(i, info.connMatrix)
        si = getIndexS(i, info);
        A(currentRow, 1:info.lengthOfX) = 0;
        A(currentRow, si) = 1;
        A(currentRow, info.optimIndex) = -1;
        b(currentRow, 1) = 0 - info.wcet(i);
        currentRow = currentRow + 1;
    end
end
if info.debugMode > 0
    fprintf('Rule 8 added %d rules\n',currentRow - 1);
end
end
