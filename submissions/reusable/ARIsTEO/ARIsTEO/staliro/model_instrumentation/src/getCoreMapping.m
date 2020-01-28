% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function assignmentArr = getCoreMapping(x, info)

if info.isMultiRate
    blockCount = info.numOfMainBlocks;
else
    blockCount = numOfBlocks(info);
end

assignmentArr = zeros(1, blockCount);
for i = 1:blockCount
    mappedCore = 0;
    for core = 1:info.numOfCores
        if int64(x(getIndexB(i, core, info))) == 1
            mappedCore = core;
            info.B(i, core) = 1;
        else
            info.B(i, core) = 0;
        end
    end
    assignmentArr(i) = mappedCore;
end
end

