% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function blocksOfDesiredDepth = getBlocksOfDesiredDepth(info)

try
    blocksOfDesiredDepth = [];
    if info.desiredDepth > 0 && info.desiredDepth < 100
        for i = 2:info.numOfBlocks
            if info.blockDepths(i) == info.desiredDepth;
                blocksOfDesiredDepth = [blocksOfDesiredDepth, i];
            end
        end
    end
catch
    error('ERROR: getBlocksOfDesiredDepth failed!');
end
end

