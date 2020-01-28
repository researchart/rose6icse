% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function i = getIndexD(srcBlock, dstBlock, info)

if dstBlock > srcBlock
    startForBlock = info.startOfD + (((srcBlock - 1) * ((2 * numOfBlocks(info)) - srcBlock)) / 2);
    i = startForBlock + dstBlock - srcBlock - 1;
else %Error (dstBlock <= srcBlock)
    fprintf('ERROR in getting index D (dstBlock(%d) <= srcBlock(%d))\n', dstBlock, srcBlock);
    i = -1;
end
end

