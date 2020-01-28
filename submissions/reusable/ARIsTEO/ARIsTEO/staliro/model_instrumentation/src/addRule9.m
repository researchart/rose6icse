% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [A, b, info] = addRule9( infoIn )
%addRule9 : Makes a decision on execution order of independent blocks i and
%j for the case they are mapped on to same core.
% Best case start time of i: BS(i)
% Worst case start time of i: WS(i)
% if [BS(i) < BS(j) && WS(i) <= WS(j)] OR [BS(i) <= BS(j) && WS(i) < WS(j)]
% then i will execute before j if they are mapped on same core.
% Creates A and b matrices for inequality rule Ax == b
% Caller must append outputs of this function to global Aeq and beq

info = infoIn;
A = [];
b = [];
currentRow = 1;
version = info.forceOrder;
if info.forceOrder > 0
    for i = 1:numOfBlocks(info)
        for j = i+1:numOfBlocks(info)
            if (info.D(i, j) == -1) && int64(info.dependencyMatrix(i, j) + info.dependencyMatrix(j, i)) == int64(0) %No path between i and j
                if int64(info.delayConn(i, j)) + int64(info.delayConn(j, i)) == int64(0) % No delay relation
                    if (version == 1 && ((info.worstStart(i) < info.worstStart(j) && info.bestStart(i) <= info.bestStart(j)) || ...
                            (info.worstStart(i) <= info.worstStart(j) && info.bestStart(i) < info.bestStart(j)))) ... 
                        || (version == 2 && (info.bestStart(i) + info.worstStart(i) <= info.bestStart(j) + info.worstStart(j)))
                        A(currentRow, 1:info.lengthOfX) = 0;
                        A(currentRow, getIndexD(i, j, info)) = 1;
                        b(currentRow, 1) = 1;
                        currentRow = currentRow + 1;
                        info.D(i, j) = 1;
                    elseif (version == 1 && ((info.worstStart(i) > info.worstStart(j) && info.bestStart(i) >= info.bestStart(j)) || ...
                            (info.worstStart(i) >= info.worstStart(j) && info.bestStart(i) > info.bestStart(j)))) ...
                        || (version == 2 && (info.bestStart(i) + info.worstStart(i) > info.bestStart(j) + info.worstStart(j)))
                        A(currentRow, 1:info.lengthOfX) = 0;
                        A(currentRow, getIndexD(i, j, info)) = 1;
                        b(currentRow, 1) = 0;
                        currentRow = currentRow + 1;
                        info.D(i, j) = 0;
                    end
                end
            end
        end
    end
end

if info.debugMode > 0
    fprintf('Rule 9 added %d rules\n',currentRow - 1);
end
end

