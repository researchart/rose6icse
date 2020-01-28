% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A, b, info ] = addRule7( infoIn )
%addRule7 : Delay block and its predecessors will be on same core
% Creates Aeq and beq matrices for rule 7
% Caller must append outputs of this function to global Aeq and beq

info = infoIn;
A = [];
b = [];
currentRow = 1;
for i = 1:numOfBlocks(info)
    for j = 1:numOfBlocks(info)
        if int64(info.delayConn(i, j)) > 0 || int64(info.sameCoreBlocks(i, j)) > 0 %i is delay, j is predecessor || i and j will be mapped on same core
            if i == j
                fprintf('Unexpected delay connection from %d to %d\n', i, j);
            else
                % Force j and i to be on same core
                if info.B(i, 1) == -1 && info.B(j, 1) == -1
                    for p = 1:info.numOfCores
                        bip = getIndexB(i, p, info);
                        bjp = getIndexB(j, p, info);
                        A(currentRow, 1:info.lengthOfX) = 0;
                        A(currentRow, bip) = 1;
                        A(currentRow, bjp) = -1;
                        b(currentRow, 1) = 0;
                        currentRow = currentRow + 1;
                    end
                elseif info.B(i, 1) == -1 && info.B(j, 1) ~= -1
                    for p = 1:info.numOfCores
                        info.B(i, p) = info.B(j, p);
                    end
                elseif info.B(i, 1) ~= -1 && info.B(j, 1) == -1
                    for p = 1:info.numOfCores
                        info.B(j, p) = info.B(i, p);
                    end
                end
            end
        end
    end
end
if info.debugMode > 0
    fprintf('Rule 7 added %d rules\n',currentRow - 1);
end
end

