% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b ] = addRule3( info )
%addRule3 : If there is a dependency from i to j execution of j cannot
%start before execution of i finishes, transmission from output of i to its
%dependents finishes and reception of inputs of i finishes.
% Creates A and b matrices for inequality rule Ax <= b
% Caller must append outputs of this function to global A and b

A = zeros(numOfBlocks(info), info.lengthOfX);
b = zeros(numOfBlocks(info), 1);
currentRow = 1;
for i = 1:numOfBlocks(info)
    si = getIndexS(i, info);
    for j = 1:numOfBlocks(info)
        if (i ~= j) && int64(info.connMatrix(i, j)) > 0
            % First check if rule is needed or lb and ub already implies
            % the rule
            txCommCostSum = sum(info.txCostMatrix(i,:));
            rxCommCostSum = sum(info.rxCostMatrix(:,j));
            if info.worstFinish(i) + txCommCostSum <= info.bestStart(j) - rxCommCostSum
                continue; %lb and ub on s values already imply the rule.
            end
            
            % Add rule
            sj = getIndexS(j, info);
            for p = 1:info.numOfCores
                % Case 1 : i and j are mapped to same core
                if info.B(i, p) ~= 0 && info.B(j, p) ~= 0 % both not decided or both on this core
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
                    for k = 1:numOfBlocks(info)
                        if (k ~= j) && (i ~= k) && (int64(info.connMatrix(i,k)) > 0)
                            A(currentRow, getIndexB(k, p, info)) = 0 - info.txCostMatrix(i,k);
                            commCostSum = commCostSum + info.txCostMatrix(i,k);
                        end
                        if (k ~= i) && (k ~= j) && (int64(info.connMatrix(k,j)) > 0)
                            A(currentRow, getIndexB(k, p, info)) = 0 - info.rxCostMatrix(k,j);
                            commCostSum = commCostSum + info.rxCostMatrix(k,j);
                        end
                    end
                    b(currentRow, 1) = double(0 - commCostSum - info.wcet(i));
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
                end
                
                % Case 2 : i and j are mapped to different cores
                for q = 1:info.numOfCores    % and j is mapped to q
                    if p ~= q           % where p and q are different cores
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
                            for k = 1:numOfBlocks(info) % TODO HERE, our original formula says that k will be less than j but since we did not sort the graph can not use it yet
                                if (i ~= k) && int64(info.connMatrix(i,k)) > 0
                                    A(currentRow, getIndexB(k, p, info)) = 0 - info.txCostMatrix(i,k);
                                    commCostSum = commCostSum + info.txCostMatrix(i,k);
                                end
                                if (k ~= j) && int64(info.connMatrix(k,j)) > 0
                                    A(currentRow, getIndexB(k, q, info)) = 0 - info.rxCostMatrix(k,j);
                                    commCostSum = commCostSum + info.rxCostMatrix(k,j);
                                end
                            end
                            b(currentRow, 1) = double(0 - commCostSum - info.wcet(i));
                            if info.B(i, p) == -1
                                b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                            end
                            if info.B(j, q) == -1
                                b(currentRow, 1) = b(currentRow, 1) + double(info.maxVal);
                            end
                            
                            currentRow = currentRow + 1;
                            if mod(currentRow, numOfBlocks(info)) == 1 % give new space to A
                                A = [A; zeros(numOfBlocks(info), info.lengthOfX)];
                                b = [b; zeros(numOfBlocks(info), 1)];
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
    fprintf('Rule 3 added %d rules (%d)\n',currentRow - 1, length(b));
end
end

