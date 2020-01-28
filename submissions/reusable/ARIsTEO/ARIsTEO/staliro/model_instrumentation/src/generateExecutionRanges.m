% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [bestStart, bestFinish, worstStart, worstFinish ] = generateExecutionRanges(info)

n = numOfBlocks(info);
% Find Best Case Start and Finish Times
readyCheckMatrix = info.connMatrix;
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
        bestOfBestStarts = info.deadline;
        found = 0;
        for j = 1:n
            if info.connMatrix(j, readyArr(i)) > 0
                totalWcet = totalWcet + info.wcet(j);
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
        bestFinish(readyArr(i)) = bestStart(readyArr(i)) + info.wcet(readyArr(i));
        isFinished(readyArr(i)) = 1;
        numOfFinished = numOfFinished + 1;
    end
end

% Find Worst Case Start and Finish Times
readyCheckMatrix = info.connMatrix;
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
        worstFinish(readyArr(i)) = info.deadline;
        totalWcet = 0;
        worstOfWorstFinish = 0;
        found = 0;
        for j = 1:n
            if info.connMatrix(readyArr(i), j) > 0
                totalWcet = totalWcet + info.wcet(j);
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
        worstStart(readyArr(i)) = worstFinish(readyArr(i)) - info.wcet(readyArr(i));
        isFinished(readyArr(i)) = 1;
        numOfFinished = numOfFinished + 1;
    end
end
end

