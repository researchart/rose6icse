% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule5_mr( info )
%addRule5_mr : Preemption constraint 1. Blocks must either finish before
%future firing time when there is a higher priority task in next firing
%time or start after all higher priority task blocks are finished
% Creates A and b matrices for inequality rule Ax <= b
% Caller must append outputs of this function to global A and b

A = [];
b = [];
currentRow = 1;

numOfAllBlocks = numel(info.blocksInHyperPeriod);

%If the block will not finish execution before an upcoming firing time, it
%can not finish execution before an even earlier firing time.
%d'_{(i_u),(w-1)} <= d'_{(i_u),(w)}
%if d'_{(i_u),(w)} (for firing time w) is 0, the same relation for the
%firing time w-1 must also be 0.
for src = 1:numOfAllBlocks % block id in hyper period
    highPrioritySampleTimes = find(info.preemptionGraph(src, :));
    for highSInd = 2:numel(highPrioritySampleTimes) % high_s sample time id in hyper period
        A(currentRow, 1:info.lengthOfX) = 0;
        A(currentRow, info.startOfP + info.preemptionGraph(src, highPrioritySampleTimes(highSInd)) - 1) = -1;
        A(currentRow, info.startOfP + info.preemptionGraph(src, highPrioritySampleTimes(highSInd - 1)) - 1) = 1;
        b(currentRow, 1) = 0;
        currentRow = currentRow + 1;
    end
end

% Equation (8) in the paper:
% A block shall finish execution and output transmission before an upcoming
% firing time where smaller period (higher priority) blocks are fired.
% NOTE THAT: this is "either" part of a rule. 
% This part is active when d' = 1
for src = 1:numOfAllBlocks % block id in hyper period
    highPrioritySampleTimes = find(info.preemptionGraph(src, :));
    for highSInd = 1:numel(highPrioritySampleTimes) % high_s sample time id in hyper period
        high_s = highPrioritySampleTimes(highSInd);
        s = info.blocksInHyperPeriod{src}.sampleTimeId;
        i = info.blocksInHyperPeriod{src}.block; %main block id
        blockIndexInSampleTime_i = find(info.sampleTimeMainBlocks{s} == i, 1);
        connMatrix = info.sampleTimeMainBlocksGraph{s};
        si = info.startOfS + src - 1;
        
        for p = 1:info.numOfCores
            A(currentRow, 1:info.lengthOfX) = 0;
            A(currentRow, si) = 1;
            if info.B(i, p) == -1
                A(currentRow, getIndexB(i, p, info)) = info.maxVal;
            end
            A(currentRow, info.startOfP + info.preemptionGraph(src, high_s) - 1) = info.maxVal;
            commCostSum = 0;
            for blockIndexInSampleTime_k = find(connMatrix(blockIndexInSampleTime_i, :) > 0)
                cost_iTok = calculateCommCost(connMatrix(blockIndexInSampleTime_i, blockIndexInSampleTime_k), 'S');
                k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k);
                A(currentRow, getIndexB(k, p, info)) = 0 - cost_iTok;
                commCostSum = commCostSum + cost_iTok;
            end
            f_high_s = info.sampleTimesInHyperPeriod{high_s}.firingTimeId;
            b(currentRow, 1) = double(info.maxVal - commCostSum - info.wcet(i) + info.firingTimes(f_high_s).time);
            if info.B(i, p) == -1
                b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
            end
            currentRow = currentRow + 1;
        end
    end
end

%Equation (9) in the paper:
%A block shall start execution after all the blocks with a smaller period
%in an upcoming firing time are finished.
% NOTE THAT: this equation is "either" part of a rule. 
% This part is active when d' = 0.
for src = 1:numOfAllBlocks % block id in hyper period
    s = info.blocksInHyperPeriod{src}.sampleTimeId;
    i = info.blocksInHyperPeriod{src}.block; %main block id
    blockIndexInSampleTime_i = find(info.sampleTimeMainBlocks{s} == i, 1);
    connMatrix = info.sampleTimeMainBlocksGraph{s};
    si = info.startOfS + src - 1;
    txCommCostSum = calculateCommCost(sum(connMatrix(blockIndexInSampleTime_i, :)), 'S');
    
    highPrioritySampleTimes = find(info.preemptionGraph(src, :));
    for highSInd = 1:numel(highPrioritySampleTimes) % high_s sample time id in hyper period
        high_s = highPrioritySampleTimes(highSInd);
        dests = info.blocksInHyperPeriodForSampleTime{high_s}; % dests: block indices for blocksInHyperPeriod
        
        for j_hp = dests % dests: block indices for blocksInHyperPeriod
            s_j = info.blocksInHyperPeriod{j_hp}.sampleTimeId;
            j = info.blocksInHyperPeriod{j_hp}.block; %original block id
            blockIndexInSampleTime_j = find(info.sampleTimeMainBlocks{s_j} == j, 1);
            
            % Check if rule is needed
            connMatrix_j = info.sampleTimeMainBlocksGraph{s_j};
            rxCommCostSum = calculateCommCost(sum(connMatrix_j(:, blockIndexInSampleTime_j)), 'R');
            if info.executionRanges{s}.worstFinish(blockIndexInSampleTime_i) + txCommCostSum ...
                    <= info.executionRanges{s_j}.bestStart(blockIndexInSampleTime_j) - rxCommCostSum
                continue; %lb and ub on s values already imply the rule.
            end
            % Add rule
            sj = info.startOfS + j_hp - 1;
            for p = 1:info.numOfCores
                % for p == q (q=p)
                %Case 1 : valid only when d = 1
                if info.B(i, p) ~= 0 && info.B(j, p) ~= 0 % both not decided or both on this core
                    A(currentRow, 1:info.lengthOfX) = 0;
                    A(currentRow, si) = -1;
                    A(currentRow, sj) = 1;
                    if info.B(i, p) == -1
                        A(currentRow, getIndexB(i, p, info)) = info.maxVal;
                    end
                    if info.B(j, p) == -1
                        A(currentRow, getIndexB(j, p, info)) = info.maxVal;
                    end
                    %info.preemptionGraph(i, high_S) contains index of P
                    A(currentRow, info.startOfP + info.preemptionGraph(src, high_s) - 1) = -info.maxVal;
                    
                    commCostSum = 0;
                    for blockIndexInSampleTime_k = find(connMatrix_j(blockIndexInSampleTime_j, :) > 0)
                        cost_jTok = calculateCommCost(connMatrix_j(blockIndexInSampleTime_j, blockIndexInSampleTime_k), 'S');
                        k = info.sampleTimeMainBlocks{s_j}(blockIndexInSampleTime_k);
                        A(currentRow, getIndexB(k, p, info)) = 0 - cost_jTok;
                        commCostSum = commCostSum + cost_jTok;
                    end
                    
                    srcs = find(connMatrix(:, blockIndexInSampleTime_i) > 0);
                    for blockIndexInSampleTime_k = srcs'
                        cost_kToi = calculateCommCost(connMatrix(blockIndexInSampleTime_k, blockIndexInSampleTime_i), 'R');
                        k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k);
                        A(currentRow, getIndexB(k, p, info)) = 0 - cost_kToi;
                        commCostSum = commCostSum + cost_kToi;
                    end
                    
                    b(currentRow, 1) = double(0 - commCostSum - info.wcet(j));
                    if info.B(i, p) == -1
                        b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                    end
                    if info.B(j, p) == -1
                        b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                    end
                    
                    currentRow = currentRow + 1;
                end
            end
        end
    end
end

%Equation (10) in the paper:
%Blocks shall not start execution until other blocks with smaller periods
%from same of previous firing times finish their execution and output
%transmission. (When these blocks are mapped on the same core)
for src = 1:numOfAllBlocks % block id in hyper period
    s = info.blocksInHyperPeriod{src}.sampleTimeId;
    i = info.blocksInHyperPeriod{src}.block; %main block id
    blockIndexInSampleTime_i = find(info.sampleTimeMainBlocks{s} == i, 1);
    connMatrix = info.sampleTimeMainBlocksGraph{s};
    si = info.startOfS + src - 1;
    rxCommCostSum = calculateCommCost(sum(connMatrix(:, blockIndexInSampleTime_i)), 'R');
    block_i_firingId = info.blocksInHyperPeriod{src}.firingTimeId;
    block_i_sampleTimeId = info.blocksInHyperPeriod{src}.sampleTimeId;
    
    earlierHighPrioritySTIndInHP = [];
    for stInd = 1:numel(info.sampleTimesInHyperPeriod)
        stInHP = info.sampleTimesInHyperPeriod{stInd};
        sampleTimeCopyCount = stInHP.copyCount;
        sampleTimeId = stInHP.sampleTimeId;
        sampleTimeFiringId = stInHP.firingTimeId;
        if (info.firingTimes(sampleTimeFiringId).time <= info.firingTimes(block_i_firingId).time) && ...
                ((sampleTimeCopyCount+1)*info.sampleTimes(sampleTimeId) > info.firingTimes(block_i_firingId).time) && ...
                (info.sampleTimes(sampleTimeId) < info.sampleTimes(block_i_sampleTimeId))
            earlierHighPrioritySTIndInHP = [earlierHighPrioritySTIndInHP, stInd];
        end
    end
    
    for ind = 1:numel(earlierHighPrioritySTIndInHP)
        stInHPInd = earlierHighPrioritySTIndInHP(ind);
        for block_j_InHP = info.blocksInHyperPeriodForSampleTime{stInHPInd}
            j = info.blocksInHyperPeriod{block_j_InHP}.block; %main block id
            sj = info.startOfS + block_j_InHP - 1;
            st_j = info.blocksInHyperPeriod{block_j_InHP}.sampleTimeId;
            connMatrix_j = info.sampleTimeMainBlocksGraph{st_j};
            blockIndexInSampleTime_j = find(info.sampleTimeMainBlocks{st_j} == j, 1);
            txCommCostSum = calculateCommCost(sum(connMatrix_j(blockIndexInSampleTime_j, :)), 'S');
            
            % Check if rule is needed
            if info.executionRanges{s}.bestStart(blockIndexInSampleTime_i) - rxCommCostSum ...
                    >= info.executionRanges{s_j}.worstFinish(blockIndexInSampleTime_j) + txCommCostSum
                continue; %lb and ub on s values already imply the rule.
            end
            
            for p = 1:info.numOfCores
                A(currentRow, 1:info.lengthOfX) = 0;
                A(currentRow, si) = -1;
                A(currentRow, sj) = 1;
                if info.B(i, p) == -1
                    A(currentRow, getIndexB(i, p, info)) = info.maxVal;
                end
                if info.B(j, p) == -1
                    A(currentRow, getIndexB(j, p, info)) = A(currentRow, getIndexB(j, p, info)) + info.maxVal;
                end
                
                commCostSum = 0;
                for blockIndexInSampleTime_k = find(connMatrix_j(blockIndexInSampleTime_j, :) > 0)
                    cost_jTok = calculateCommCost(connMatrix_j(blockIndexInSampleTime_j, blockIndexInSampleTime_k), 'S');
                    k = info.sampleTimeMainBlocks{st_j}(blockIndexInSampleTime_k);
                    A(currentRow, getIndexB(k, p, info)) = A(currentRow, getIndexB(k, p, info)) - cost_jTok;
                    commCostSum = commCostSum + cost_jTok;
                end

                srcs = find(connMatrix(:, blockIndexInSampleTime_i) > 0);
                for blockIndexInSampleTime_k = srcs'
                    cost_kToi = calculateCommCost(connMatrix(blockIndexInSampleTime_k, blockIndexInSampleTime_i), 'R');
                    k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k);
                    A(currentRow, getIndexB(k, p, info)) = A(currentRow, getIndexB(k, p, info)) - cost_kToi;
                    commCostSum = commCostSum + cost_kToi;
                end

                b(currentRow, 1) = double(0 - commCostSum - info.wcet(j));
                if info.B(i, p) == -1
                    b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                end
                if info.B(j, p) == -1
                    b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                end

                currentRow = currentRow + 1;
                
            end
        end
    end
end


if info.debugMode > 0
    fprintf('Rule 5_mr added %d rules (%d)\n', currentRow - 1, length(b));
end
end

