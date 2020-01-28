% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = generateExecutionRanges_mr(infoIn)
%generateExecutionRanges_mr: Calculates best and worst case start times for
%blocks in every sampleTime.
%try
    info = infoIn;
    
    numOfSampleTimes = numel(info.sampleTimes);
    for s = 1:numOfSampleTimes
        connMatrix = info.sampleTimeMainBlocksGraph{s};
        n = length(connMatrix);
        readyCheckMatrix = connMatrix;
        isFinished = zeros(1, n);
        bestStart = zeros(n, 1);
        bestFinish = zeros(n, 1);
        numOfFinished = 0;
        
        while numOfFinished < n
            readyArr = [];
            for i = 1:n
                if isempty(find(readyCheckMatrix(:, i), 1)) && isFinished(i) == 0
                    readyArr = [readyArr; i];
                end
            end
            for i = 1:length(readyArr)
                bestStart(readyArr(i)) = 0;
                totalWcet = 0;
                bestOfBestStarts = info.sampleTimes(s);
                found = 0;
                for j = 1:n
                    if connMatrix(j, readyArr(i)) > 0
                        orgBlockId = info.sampleTimeMainBlocks{s}(j);
                        totalWcet = totalWcet + info.wcet(orgBlockId);
                        if bestOfBestStarts > bestStart(j)
                            bestOfBestStarts = bestStart(j);
                        end
                        if bestStart(readyArr(i)) < bestFinish(j)
                            bestStart(readyArr(i)) = bestFinish(j);
                        end
                        found = 1;
                    end
                    readyCheckMatrix(readyArr(i), j) = 0;
                end
                if found == 1 %not first level blocks
                    bestStart(readyArr(i)) = max(bestStart(readyArr(i)), bestOfBestStarts + (totalWcet / info.numOfCores));
                end
                orgBlockId = info.sampleTimeMainBlocks{s}(readyArr(i));
                bestFinish(readyArr(i)) = bestStart(readyArr(i)) + info.wcet(orgBlockId);
                isFinished(readyArr(i)) = 1;
                numOfFinished = numOfFinished + 1;
            end
        end
        info.executionRanges{s}.bestStart = bestStart;
        info.executionRanges{s}.bestFinish = bestFinish;
    end
       
    for s = 1:numOfSampleTimes
        % Find Worst Case Start and Finish Times
        connMatrix = info.sampleTimeMainBlocksGraph{s};
        n = length(connMatrix);
        readyCheckMatrix = connMatrix;
        isFinished = zeros(1, n);
        worstStart = zeros(n, 1);
        worstFinish = zeros(n, 1);
        numOfFinished = 0;
        
        while numOfFinished < n
            readyArr = [];
            for i = 1:n
                if isempty(find(readyCheckMatrix(i, :), 1)) && isFinished(i) == 0
                    readyArr = [readyArr; i];
                end
            end
            for i = 1:length(readyArr)
                worstFinish(readyArr(i)) = info.sampleTimes(s);
                totalWcet = 0;
                worstOfWorstFinish = 0;
                found = 0;
                for j = 1:n
                    if connMatrix(readyArr(i), j) > 0
                        orgBlockId = info.sampleTimeMainBlocks{s}(j);
                        totalWcet = totalWcet + info.wcet(orgBlockId);
                        if worstOfWorstFinish < worstFinish(j)
                            worstOfWorstFinish = worstFinish(j);
                        end
                        if worstFinish(readyArr(i)) > worstStart(j)
                            worstFinish(readyArr(i)) = worstStart(j);
                        end
                        found = 1;
                    end
                    readyCheckMatrix(j, readyArr(i)) = 0;
                end
                if found == 1
                    worstFinish(readyArr(i)) = min(worstFinish(readyArr(i)), worstOfWorstFinish - (totalWcet / info.numOfCores));
                end
                orgBlockId = info.sampleTimeMainBlocks{s}(readyArr(i));
                worstStart(readyArr(i)) = worstFinish(readyArr(i)) - info.wcet(orgBlockId);
                isFinished(readyArr(i)) = 1;
                numOfFinished = numOfFinished + 1;
            end
        end
        
        info.executionRanges{s}.worstStart = worstStart;
        info.executionRanges{s}.worstFinish = worstFinish;
    end
%catch
%    error('ERROR: generateExecutionRanges_mr failed !');
%end
end

