% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule4( info )
%addRule4 : Execution of independent blocks that are mapped on same core 
%cannot overlap
% Creates A and b matrices for inequality rule Ax <= b
% Caller must append outputs of this function to global A and b

A = zeros(numOfBlocks(info), info.lengthOfX);
b = zeros(numOfBlocks(info), 1);
currentRow = 1;

for i = 1:numOfBlocks(info)
    for j = i+1:numOfBlocks(info)
        if int64(info.dependencyMatrix(i, j) + info.dependencyMatrix(j, i)) == int64(0) %No path between i and j
            if info.D(i, j) < 0 %dij not decided yet
                % Check if rule is needed or lb and ub already implies
                % the rule
                txCommCostSumi = sum(info.txCostMatrix(i,:));
                txCommCostSumj = sum(info.txCostMatrix(j,:));
                rxCommCostSumi = sum(info.rxCostMatrix(:,i));
                rxCommCostSumj = sum(info.rxCostMatrix(:,j));
                if info.worstFinish(i) + txCommCostSumi <= info.bestStart(j) - rxCommCostSumj
                    info.D(i, j) = 1;
                    continue;
                elseif info.worstFinish(j) + txCommCostSumj <= info.bestStart(i) - rxCommCostSumi
                    info.D(i, j) = 0;
                    continue; %lb and ub on s values already imply the rule.
                end
            
                if info.forceOrder == 1
                    if (info.worstStart(i) < info.worstStart(j) && info.bestStart(i) <= info.bestStart(j)) || ...
                        (info.worstStart(i) <= info.worstStart(j) && info.bestStart(i) < info.bestStart(j)) % i will execute before j
                        info.D(i, j) = 1;
                    elseif (info.worstStart(i) > info.worstStart(j) && info.bestStart(i) >= info.bestStart(j)) || ...
                            (info.worstStart(i) >= info.worstStart(j) && info.bestStart(i) > info.bestStart(j)) % j will execute before i
                        info.D(i, j) = 0;
                    end
                end
            end
            
            si = getIndexS(i, info);
            sj = getIndexS(j, info);
            for p = 1:info.numOfCores
                if info.B(i, p) ~= 0 && info.B(j, p) ~= 0 % both not decided or both on this core
                    % Case 1: i is executed before j
                    if info.D(i, j) ~= 0 %dij == 1 or not decided
                        A(currentRow, 1:info.lengthOfX) = 0;
                        A(currentRow, si) = 1;
                        A(currentRow, sj) = -1;
                        commCostSum = 0;
                        for k = 1:numOfBlocks(info)
                            if (i ~= k) && int64(info.connMatrix(i,k)) > 0
                                A(currentRow, getIndexB(k, p, info)) = 0 - info.txCostMatrix(i,k);
                                commCostSum = commCostSum + info.txCostMatrix(i,k);
                            end
                            if (k ~= j) && int64(info.connMatrix(k,j)) > 0
                                A(currentRow, getIndexB(k, p, info)) = A(currentRow, getIndexB(k, p, info)) - info.rxCostMatrix(k,j);
                                commCostSum = commCostSum + info.rxCostMatrix(k,j);
                            end
                        end
                        if info.B(i, p) == -1
                            A(currentRow, getIndexB(i, p, info)) = info.maxVal;
                        end
                        if info.B(j, p) == -1
                            A(currentRow, getIndexB(j, p, info)) = info.maxVal;
                        end
                        if info.D(i, j) == 1
                            b(currentRow, 1) = double(0 - commCostSum - info.wcet(i));
                        else
                            A(currentRow, getIndexD(i, j, info)) = info.maxVal;
                            b(currentRow, 1) = double((info.maxVal) - commCostSum - info.wcet(i));
                        end
                        if info.B(i, p) == -1
                            b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                        end
                        if info.B(j, p) == -1
                            b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                        end
                        currentRow = currentRow + 1;
                        if mod(currentRow, numOfBlocks(info)) == 1 % give new space to A
                            A = [A; zeros(numOfBlocks(info), info.lengthOfX)];
                            b = [b; zeros(numOfBlocks(info), 1)];
                        end
                        if info.debugMode > 0
                            if mod(currentRow, 100) == 0
                                fprintf('.');
                            end
                        end
                    end

                    % Case 2: j is executed before i
                    if info.D(i, j) ~= 1 %dij == 0 or not decided
                        A(currentRow, 1:info.lengthOfX) = 0;
                        A(currentRow, sj) = 1;
                        A(currentRow, si) = -1;
                        commCostSum = 0;
                        for k = 1:numOfBlocks(info)
                            if (j ~= k) && int64(info.connMatrix(j,k)) > 0
                                A(currentRow, getIndexB(k, p, info)) = 0 - info.txCostMatrix(j,k);
                                commCostSum = commCostSum + info.txCostMatrix(j,k);
                            end
                            if (k ~= i) && int64(info.connMatrix(k,i)) > 0
                                A(currentRow, getIndexB(k, p, info)) = A(currentRow, getIndexB(k, p, info)) - info.rxCostMatrix(k,i);
                                commCostSum = commCostSum + info.rxCostMatrix(k,i);
                            end
                        end
                        if info.B(i, p) == -1
                            A(currentRow, getIndexB(i, p, info)) = info.maxVal;
                        end
                        if info.B(j, p) == -1
                            A(currentRow, getIndexB(j, p, info)) = info.maxVal;
                        end
                        if info.D(i, j) == -1 %not decided
                            A(currentRow, getIndexD(i, j, info)) = 0 - info.maxVal;
                        end
                        b(currentRow, 1) = double(0 - commCostSum - info.wcet(j));
                        if info.B(i, p) == -1
                            b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                        end
                        if info.B(j, p) == -1
                            b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                        end
                        currentRow = currentRow + 1;
                        if mod(currentRow, numOfBlocks(info)) == 1 % give new space to A
                            A = [A; zeros(numOfBlocks(info), info.lengthOfX)];
                            b = [b; zeros(numOfBlocks(info), 1)];
                        end
                        if info.debugMode > 0
                            if mod(currentRow, 100) == 0
                                fprintf('.');
                            end
                        end
                    end
                end
            end
        end
    end
end
if currentRow <= length(b) %delete back extra assigned space
    A(currentRow:end,:) = [];
    b(currentRow:end,:) = [];
end
if info.debugMode > 0
    fprintf('\nRule 4 added %d rules (%d)\n',currentRow - 1, length(b));
end
end
