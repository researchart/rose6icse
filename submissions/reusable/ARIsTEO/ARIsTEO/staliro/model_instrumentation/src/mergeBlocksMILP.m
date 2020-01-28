% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [info, merged] = mergeBlocksMILP(src, dst, child, checkAgainstCycles, infoIn, extraFeatures)

info = infoIn;

if nargin < 6
    extraFeatures = 0;
end
conn = info.connMatrix;
if child == src || child == -1 %child == -1 means they are both child of each other
    conn(dst, src) = 0;
end
if child == dst || child == -1
    conn(src, dst) = 0;
end
conn(dst, 1:end) = conn(dst, 1:end) + conn(src, 1:end);
conn(1:end, dst) = conn(1:end, dst) + conn(1:end, src);
conn(src, :) = [];
conn(:, src) = [];

if checkAgainstCycles > 0
    [conn, cycleExist] = removeCycles(conn, info.debugMode);
    if cycleExist == 0
        merged = 1;
    else
        merged = 0;
    end
else
    merged = 1;
end
if merged == 1
    info.connMatrix = conn;
    info.wcet(dst) = info.wcet(dst) + info.wcet(src);
    info.wcet(src) = [];
    
 
    info.delayConn(dst, 1:end) = info.delayConn(dst, 1:end) + info.delayConn(src, 1:end);
    info.delayConn(1:end, dst) = info.delayConn(1:end, dst) + info.delayConn(1:end, src);
    info.delayConn(src, :) = [];
    info.delayConn(:, src) = [];
    
    info.sameCoreBlocks(dst, 1:end) = info.sameCoreBlocks(dst, 1:end) + info.sameCoreBlocks(src, 1:end);
    info.sameCoreBlocks(1:end, dst) = info.sameCoreBlocks(1:end, dst) + info.sameCoreBlocks(1:end, src);
    info.sameCoreBlocks(src, :) = [];
    info.sameCoreBlocks(:, src) = [];
    
    info.mergedList{dst} = [info.mergedList{dst}, info.mergedList{src}];
    %mergedList{dst}
    info.mergedList(src) = [];
    if extraFeatures == 1
        if (child == src)
            info.txCostMatrix(dst, child) = 0;
        elseif (child == dst)
            info.txCostMatrix(src, child) = 0;
        end
        info.txCostMatrix(dst, 1:end) = info.txCostMatrix(dst, 1:end) + info.txCostMatrix(src, 1:end);
        info.txCostMatrix(1:end, dst) = info.txCostMatrix(1:end, dst) + info.txCostMatrix(1:end, src);
        info.txCostMatrix(src, :) = [];
        info.txCostMatrix(:, src) = [];
        
        if (child == src)
            info.rxCostMatrix(dst, child) = 0;
        elseif (child == dst)
            info.rxCostMatrix(src, child) = 0;
        end
        info.rxCostMatrix(dst, 1:end) = info.rxCostMatrix(dst, 1:end) + info.rxCostMatrix(src, 1:end);
        info.rxCostMatrix(1:end, dst) = info.rxCostMatrix(1:end, dst) + info.rxCostMatrix(1:end, src);
        info.rxCostMatrix(src, :) = [];
        info.rxCostMatrix(:, src) = [];
        if (child == src)
            info.dependencyMatrix(dst, child) = 0;
        elseif (child == dst)
            info.dependencyMatrix(src, child) = 0;
        end
        info.dependencyMatrix(dst, 1:end) = info.dependencyMatrix(dst, 1:end) + info.dependencyMatrix(src, 1:end);
        info.dependencyMatrix(1:end, dst) = info.dependencyMatrix(1:end, dst) + info.dependencyMatrix(1:end, src);
        info.dependencyMatrix(src, :) = [];
        info.dependencyMatrix(:, src) = [];
    end
end
end
