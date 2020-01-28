% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function info = doAllMergeMILP(infoIn)
info = infoIn;

mergeCount = 1;
while mergeCount > 0
    [info, mergeCount] = exploreMergesMILP(info, 1);
end
if info.debugMode > 0
    fprintf('Number of blocks after merging: %d.\n', length(info.connMatrix));
end
end

