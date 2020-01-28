% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule3_mr( info )
%addRule3_mr : If there is a dependency from i to j execution of j cannot
%start before execution of i finishes, transmission from output of i to its
%dependents finishes and reception of inputs of i finishes.
% Creates A and b matrices for inequality rule Ax <= b
% Caller must append outputs of this function to global A and b

A = [];
b = [];
currentRow = 1;

%Equation (5): If there is a dependency from i to j execution of j cannot
%start before execution of i finishes, transmission from output of i to its
%dependents finishes and reception of inputs of i finishes.
numOfAllBlocks = numel(info.blocksInHyperPeriod);
for src = 1:numOfAllBlocks % block id in hyper period
    f = info.blocksInHyperPeriod{src}.firingTimeId;
    s = info.blocksInHyperPeriod{src}.sampleTimeId;
	sInHp = info.blocksInHyperPeriod{src}.sampleTimeInHP;
    i = info.blocksInHyperPeriod{src}.block; %main block id
    blockIndexInSampleTime_i = find(info.sampleTimeMainBlocks{s} == i, 1);
    connMatrix = info.sampleTimeMainBlocksGraph{s};  
    si = info.startOfS + src - 1;
    dests = find(connMatrix(blockIndexInSampleTime_i, :) > 0); % dests: block ids in sample time
    dests = setdiff(dests, blockIndexInSampleTime_i);
    
    if ~isempty(dests)
        txCommCostSum = calculateCommCost(sum(connMatrix(blockIndexInSampleTime_i, :)), 'S');
        for blockIndexInSampleTime_j = dests
            j = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_j); %main block id
            dst = info.blocksInHyperPeriodForSampleTime{sInHp}(blockIndexInSampleTime_j); %block id in hyperperiod

            % Check if rule is needed
            rxCommCostSum = calculateCommCost(sum(connMatrix(:, blockIndexInSampleTime_j)), 'R');
            if info.executionRanges{s}.worstFinish(blockIndexInSampleTime_i) + txCommCostSum ...
                    <= info.executionRanges{s}.bestStart(blockIndexInSampleTime_i)-rxCommCostSum
                continue; %lb and ub on s values already imply the rule.
            end

            % Add rule
            sj = info.startOfS + dst - 1;
            for p = 1:info.numOfCores
                for q = 1:info.numOfCores    % and j is mapped to q
                    if info.B(i, p) ~= 0 && info.B(j, q) ~= 0 % both not decided or i is on p and j is on q
                        A(currentRow, 1:info.lengthOfX) = 0;
                        A(currentRow, si) = 1;
                        A(currentRow, sj) = -1;
                        if info.B(i, p) == -1
                            A(currentRow, getIndexB(i, p, info)) = info.maxVal;
                        end
                        if info.B(j, q) == -1
                            A(currentRow, getIndexB(j, q, info)) = info.maxVal;
                        end
                        commCostSum = 0;
                        destToCheck = dests;
                        % Here Case 1 is for p == q (q=p) and Case 2 is for p != q.
                        % Case 1 : i and j are mapped to same core (p == q) -> No
                        % communication cost from i to j.
                        % Case 2 : i and j are mapped to different cores
                        if p == q
                            destToCheck = setdiff(destToCheck, blockIndexInSampleTime_j);
                        end
                        for blockIndexInSampleTime_k = destToCheck
                            cost_iTok = calculateCommCost(connMatrix(blockIndexInSampleTime_i, blockIndexInSampleTime_k), 'S');
                            k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k); %Original block id
                            if k ~= j %if b_(j,p) == 1 -> this constraint will not be valid. No need to add comm cost related part for it.
                                A(currentRow, getIndexB(k, p, info)) = 0 - cost_iTok;
                            end
                            commCostSum = commCostSum + cost_iTok;
                        end

                        srcs = find(connMatrix(:, blockIndexInSampleTime_j) > 0);
                        srcs = srcs';
                        if p == q
                            srcs = setdiff(srcs, blockIndexInSampleTime_i);
                        end
                        for blockIndexInSampleTime_k = srcs
                            cost_kToj = calculateCommCost(connMatrix(blockIndexInSampleTime_k, blockIndexInSampleTime_j), 'R');
                            k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k); %Original block id
                            if k ~= i %if b_(i,q) == 1 -> this constraint will not be valid. No need to add comm cost related part for it.
                                A(currentRow, getIndexB(k, q, info)) = 0 - cost_kToj;
                            end
                            commCostSum = commCostSum + cost_kToj;
                        end

                        b(currentRow, 1) = double(0 - commCostSum - info.wcet(i));
                        if info.B(i, p) == -1
                            b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                        end
                        if info.B(j, q) == -1
                            b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                        end

                        currentRow = currentRow + 1;
                    else
                        fprintf('already decided b %d,%d - %d,%d\n', i,p,j,q);
                    end
                end
            end
        end
    end
    
    %Below code looks like it is adding the rule " Blocks shall not start
    %execution until other blocks with smaller periods from same or
    %previous firing times finish their execution and transmission of their
    %outputs when these blocks are mapped to same core.
    % But data receive cost part is missing and this rule is already added
    % in addRule5_mr. So Commenting out this code.
%     for m = 1:numel(info.sampleTimesInHyperPeriod)
%         f_m = info.sampleTimesInHyperPeriod{m}.firingTimeId;
%         if f_m == f || ...
%                 (info.firingTimes(f_m).time > info.firingTimes(f).time ...
%                 && info.firingTimes(f_m).time < info.firingTimes(f).time + info.sampleTimes(s))
%             low_s = info.sampleTimesInHyperPeriod{m}.sampleTimeId;
%             if info.sampleTimes(low_s) > info.sampleTimes(s) %higher sample period = lower priority
%                 rootsOfLowerPriority = [];
%                 for j = 1:numel(info.sampleTimeMainBlocks{low_s})
%                     rootsOfLowerPriority = [rootsOfLowerPriority, j]; % not only to roots, to all blocks
%                 end
%                 
%                 for blockIndexInSampleTime_j = rootsOfLowerPriority
%                     j = info.sampleTimeMainBlocks{low_s}(blockIndexInSampleTime_j); %main block id
%                     dst = info.blocksInHyperPeriodForSampleTime{low_s}(blockIndexInSampleTime_j); %block id in hyperperiod
%                     
%                     % Add rule
%                     sj = info.startOfS + dst - 1;
%                     for p = 1:info.numOfCores
%                         % Here Case 1 is for p == q (q=p) and Case 2 is for p != q.
%                         % Case 1 : i and j are mapped to same core (p == q) -> No
%                         % communication cost from i to j.
%                         if info.B(i, p) ~= 0 && info.B(j, p) ~= 0 % both not decided or both on this core
%                             A(currentRow, 1:info.lengthOfX) = 0;
%                             A(currentRow, si) = 1;
%                             A(currentRow, sj) = -1;
%                             if info.B(i, p) == -1
%                                 A(currentRow, getIndexB(i, p, info)) = info.maxVal;
%                             end
%                             if info.B(j, p) == -1
%                                 A(currentRow, getIndexB(j, p, info)) = info.maxVal;
%                             end
%                             commCostSum = 0;
%                             for blockIndexInSampleTime_k = setdiff(dests, blockIndexInSampleTime_j)
%                                 cost_iTok = calculateCommCost(connMatrix(blockIndexInSampleTime_i, blockIndexInSampleTime_k), 'S');
%                                 k = info.sampleTimeMainBlocks{s}(blockIndexInSampleTime_k); %Original block id
%                                 A(currentRow, getIndexB(k, p, info)) = 0 - cost_iTok;
%                                 commCostSum = commCostSum + cost_iTok;
%                             end
%                             
%                             b(currentRow, 1) = double(0 - commCostSum - info.wcet(i));
%                             if info.B(i, p) == -1
%                                 b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
%                             end
%                             if info.B(j, p) == -1
%                                 b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
%                             end
%                             
%                             currentRow = currentRow + 1;
%                         end
%                     end
%                 end                
%             end
%         end
%     end
end

if info.debugMode > 0
    fprintf('Rule 3_mr added %d rules (%d)\n', currentRow - 1, length(b));
end
end

