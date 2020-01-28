% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function relatedIndex = getIndexFromHandle(blockHandle, handleArr)
%getIndexFromHandle Returns index of block with given handle, 0 if handle is not found

try
    relatedIndex = -1;
    for i = 1:length(handleArr)
        if handleArr(i) == blockHandle
            relatedIndex = i;
            break
        end
    end
catch
    error('ERROR: getIndexFromHandle failed!');
end
end

