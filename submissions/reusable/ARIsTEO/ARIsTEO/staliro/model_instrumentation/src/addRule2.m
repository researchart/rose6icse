% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule2( info )
%addRule2 : Finishing time of each leaf must be less than deadline
% Creates A and b matrices for rule 2
% Caller must append outputs of this function to global A and b

A = [];
b = [];
currentRow = 1;
for i = 1:numOfBlocks(info)
    if isBlockLeaf(i, info.connMatrix)
        A(currentRow, 1:info.lengthOfX) = 0;
        A(currentRow, getIndexS(i, info)) = 1;
        b(currentRow, 1) = info.worstStart(i);
        currentRow = currentRow + 1;
    end
end
if info.debugMode > 0
    fprintf('Rule 2 added %d rules\n',currentRow - 1);
end
end
