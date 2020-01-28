% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule6_mr( info )
%addRule6_mr : Total memory needed for semaphores and communication
%buffers must be less than total amount of available shared memory
% Creates A and b matrices for inequality rule Ax <= b
% Caller must append outputs of this function to global A and b
% Since rule compare absolute value, we add 2 constraints for each rule
% using the fact that |a-b| < c is equivalent to a-b < c and -a+b < c

A = [];
b = [];
currentRow = 1;

numOfAllBlocks = info.numOfMainBlocks;
for i = 1:numOfAllBlocks
    for s = 1:numel(info.sampleTimes)
        connMatrix = info.sampleTimeMainBlocksGraph{s};
        srcIndexInSampleTime = find(info.sampleTimeMainBlocks{s} == i, 1);
        if ~isempty(srcIndexInSampleTime)
            dests = find(connMatrix(srcIndexInSampleTime, :) > 0); % dests: block ids in sample time
            for dstIndexInSampleTime = dests
                j = info.sampleTimeMainBlocks{s}(dstIndexInSampleTime); %main block id for dst
                % Add rule
                for p = 1:info.numOfCores
                    memNeed = int64(info.archConfig.semaphoreSize) + (int64(info.archConfig.alignmentSize) * ceil(int64(connMatrix(srcIndexInSampleTime, dstIndexInSampleTime)) / int64(info.archConfig.alignmentSize)));
                    A(currentRow, 1:info.lengthOfX) = 0;
                    %add checks if Bip if already decided or not.
                    A(currentRow, getIndexB(i, p, info)) = double(memNeed);
                    A(currentRow, getIndexB(j, p, info)) = 0 - double(memNeed);
                    b(currentRow, 1) = double(info.archConfig.totalSharedMemory);
                    currentRow = currentRow + 1;

                    A(currentRow, 1:info.lengthOfX) = 0;
                    %add checks if Bip if already decided or not.
                    A(currentRow, getIndexB(i, p, info)) = 0 - double(memNeed);
                    A(currentRow, getIndexB(j, p, info)) = double(memNeed);
                    b(currentRow, 1) = double(info.archConfig.totalSharedMemory);
                    currentRow = currentRow + 1;
                end
            end
        end
    end
end

if info.debugMode > 0
    fprintf('Rule 6_mr added %d rules\n',currentRow - 1);
end
end

