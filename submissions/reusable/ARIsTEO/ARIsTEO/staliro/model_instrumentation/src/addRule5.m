% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule5( info )
%addRule5 : Total memory needed for semaphores and communication
%buffers must be less than total amount of available shared memory
% Creates A and b matrices for inequality rule Ax <= b
% Caller must append outputs of this function to global A and b
% Since rule compare absolute value, we add 2 constraints for each rule
% using the fact that |a-b| < c is equivalent to a-b < c and -a+b < c

A = [];
b = [];
currentRow = 1;
for i = 1:numOfBlocks(info)
    for j = 1:numOfBlocks(info)
        if (i ~= j) && int64(info.connMatrix(i, j)) > 0
            for p = 1:info.numOfCores
                memNeed = int64(info.semSize) + (int64(info.alignmentSize) * ceil(int64(info.connMatrix(i, j)) / int64(info.alignmentSize)));
                A(currentRow, 1:info.lengthOfX) = 0;
                %add checks if Bip if already decided or not.
                A(currentRow, getIndexB(i, p, info)) = double(memNeed);
                A(currentRow, getIndexB(j, p, info)) = 0 - double(memNeed);
                b(currentRow, 1) = double(info.totalSharedMemory);
                currentRow = currentRow + 1;
                
                A(currentRow, 1:info.lengthOfX) = 0;
                %add checks if Bip if already decided or not.
                A(currentRow, getIndexB(i, p, info)) = 0 - double(memNeed);
                A(currentRow, getIndexB(j, p, info)) = double(memNeed);
                b(currentRow, 1) = double(info.totalSharedMemory);
                currentRow = currentRow + 1;
            end
        end
    end
end
if info.debugMode > 0
    fprintf('Rule 5 added %d rules\n',currentRow - 1);
end
end

