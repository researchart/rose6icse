% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule4_mr( info )
%addRule4_mr : If there is no dependency from i to j execution of j cannot
%overlap with execution of i when they are on same core.
% Creates A and b matrices for inequality rule Ax <= b
% Caller must append outputs of this function to global A and b

A = [];
b = [];
currentRow = 1;

numOfAllBlocks = numel(info.blocksInHyperPeriod);
for src = 1:numOfAllBlocks % block id in hyper period
    s = info.blocksInHyperPeriod{src}.sampleTimeId;
	sInHp = info.blocksInHyperPeriod{src}.sampleTimeInHP;
    i = info.blocksInHyperPeriod{src}.block; %main block id
    blockIndexInSampleTime_i = find(info.sampleTimeMainBlocks{s} == i, 1);
    connMatrix = info.sampleTimeMainBlocksGraph{s};
    si = info.startOfS + src - 1;
    dests = find(info.independencyGraph(i, :)); % dests: main block ids 
    %The info.independencyGraph contains independencies among the blocks of
    %same period (except for rate transition blocks)
    
    txCommCostSum = calculateCommCost(sum(connMatrix(blockIndexInSampleTime_i, :)), 'S');
    if ~isempty(dests)
        for j = dests
            blockIndexInSampleTime_j = find(info.sampleTimeMainBlocks{s} == j, 1);
            dst = info.blocksInHyperPeriodForSampleTime{sInHp}(blockIndexInSampleTime_j); %block id in hyperperiod
            if isempty(dst) %Sample times do not match. This is need to because rate transition blocks will have independency entries from both sample times
                continue;
            end
            % Check if rule is needed
            rxCommCostSum = calculateCommCost(sum(connMatrix(:, blockIndexInSampleTime_j)), 'R');
            if info.executionRanges{s}.worstFinish(blockIndexInSampleTime_i) + txCommCostSum ...
                    <= info.executionRanges{s}.bestStart(blockIndexInSampleTime_i)-rxCommCostSum
                continue; %lb and ub on s values already imply the rule.
            end

            % Add rule
            sj = info.startOfS + dst - 1;
            for p = 1:info.numOfCores
                % for p == q (q=p) 
                %Case 1 : valid only when d = 1
                if info.B(i, p) ~= 0 && info.B(j, p) ~= 0 % both not decided or both on this core
                    %Case 1 : valid only when d = 1
                    A(currentRow, 1:info.lengthOfX) = 0;
                    A(currentRow, si) = 1;
                    A(currentRow, sj) = -1;
                    if info.B(i, p) == -1
                        A(currentRow, getIndexB(i, p, info)) = info.maxVal;
                    end
                    if info.B(j, p) == -1
                        A(currentRow, getIndexB(j, p, info)) = info.maxVal;
                    end
                    commCostSum = 0;
                    for blockIndexInSampleTime_k = find(connMatrix(blockIndexInSampleTime_i, :) > 0)
                        cost_iTok = calculateCommCost(connMatrix(blockIndexInSampleTime_i, blockIndexInSampleTime_k), 'S');
                        k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k); %Original block id
                        A(currentRow, getIndexB(k, p, info)) = 0 - cost_iTok;
                        commCostSum = commCostSum + cost_iTok;
                    end

                    srcs = find(connMatrix(:, blockIndexInSampleTime_j) > 0);
                    for blockIndexInSampleTime_k = setdiff(srcs', blockIndexInSampleTime_i)
                        cost_kToj = calculateCommCost(connMatrix(blockIndexInSampleTime_k, blockIndexInSampleTime_j), 'R');
                        k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k); %Original block id
                        A(currentRow, getIndexB(k, p, info)) = 0 - cost_kToj;
                        commCostSum = commCostSum + cost_kToj;
                    end

                    b(currentRow, 1) = double(0 - commCostSum - info.wcet(i));
                    if info.B(i, p) == -1
                        b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                    end
                    if info.B(j, p) == -1
                        b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                    end

                    %info.independencyGraph(i, j) contains index of D
                    A(currentRow, info.startOfD + info.independencyGraph(i, j) - 1) = info.maxVal;
                    b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);

                    currentRow = currentRow + 1;

                    %Case 2 : valid only when d = 0
                    A(currentRow, 1:info.lengthOfX) = 0;
                    A(currentRow, si) = -1;
                    A(currentRow, sj) = 1;
                    if info.B(i, p) == -1
                        A(currentRow, getIndexB(i, p, info)) = info.maxVal;
                    end
                    if info.B(j, p) == -1
                        A(currentRow, getIndexB(j, p, info)) = info.maxVal;
                    end
                    commCostSum = 0;
                    indicesToSearch = find(connMatrix(blockIndexInSampleTime_j, :) > 0);
                    if ~isempty(indicesToSearch)
                        for blockIndexInSampleTime_k = indicesToSearch
                            cost_jTok = calculateCommCost(connMatrix(blockIndexInSampleTime_j, blockIndexInSampleTime_k), 'S');
                            k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k); %Original block id
                            A(currentRow, getIndexB(k, p, info)) = 0 - cost_jTok;
                            commCostSum = commCostSum + cost_jTok;
                        end
                    end

                    srcs = find(connMatrix(:, blockIndexInSampleTime_i) > 0);
                    if ~isempty(srcs)
                        for blockIndexInSampleTime_k = srcs'
                            cost_kToi = calculateCommCost(connMatrix(blockIndexInSampleTime_k, blockIndexInSampleTime_i), 'R');
                            k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k); %Original block id
                            A(currentRow, getIndexB(k, p, info)) = 0 - cost_kToi;
                            commCostSum = commCostSum + cost_kToi;
                        end
                    end
                    b(currentRow, 1) = double(0 - commCostSum - info.wcet(j));

                    if info.B(i, p) == -1
                        b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                    end
                    if info.B(j, p) == -1
                        b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                    end

                    %info.independencyGraph(i, j) contains index of D
                    A(currentRow, info.startOfD + info.independencyGraph(i, j) - 1) = -info.maxVal;

                    currentRow = currentRow + 1;
                end
            end
        end
    end
end

if info.debugMode > 0
    fprintf('Rule 4_mr added %d rules (%d)\n', currentRow - 1, length(b));
end
end

