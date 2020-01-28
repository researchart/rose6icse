% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule2_mr( info )
%addRule2_mr : Start time of each block must be larger than its firing time

A = [];
b = [];
try
    currentRow = 1;
    numOfAllBlocks = numel(info.blocksInHyperPeriod);
    for i = 1:numOfAllBlocks
        f = info.blocksInHyperPeriod{i}.firingTimeId;
        s = info.blocksInHyperPeriod{i}.sampleTimeId;
        blockId = info.blocksInHyperPeriod{i}.block;
        blockIndexInSampleTime = find(info.sampleTimeMainBlocks{s} == blockId, 1);
        fTime = info.firingTimes(f).time;
        
        if isempty(blockIndexInSampleTime)
            fprintf('ERROR: addRule2_mr: error in indexing \n');
        else
            %rule for start time (> firingtime + bestStart time)
            A(currentRow, 1:info.lengthOfX) = 0;
            A(currentRow, info.startOfS + i - 1) = -1;
            b(currentRow, 1) = double(-fTime - info.executionRanges{s}.bestStart(blockIndexInSampleTime));
            currentRow = currentRow + 1;
            
            %rule for finish time (< firing time + worst start time)
            A(currentRow, 1:info.lengthOfX) = 0;
            A(currentRow, info.startOfS + i - 1) = 1;
            b(currentRow, 1) = double(fTime + info.executionRanges{s}.worstStart(blockIndexInSampleTime));
            currentRow = currentRow + 1;
        end
    end
    if info.debugMode > 0
        fprintf('Rule 2 mr added %d rules\n', currentRow - 1);
    end
catch
    error('ERROR: addRule2_mr failed!');
end
end
