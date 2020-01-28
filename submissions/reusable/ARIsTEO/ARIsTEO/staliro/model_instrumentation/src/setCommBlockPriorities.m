% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [  ] = setCommBlockPriorities( info )
%setCommBlockPriorities Sets sorted priorities for IC Comm block pairs

try
    tempICPairArr = zeros(numel(info.ICCommPairArray), 5);
    for i = 1:numel(info.ICCommPairArray)
        tempICPairArr(i, 1) = info.ICCommPairArray(i).dataReadyTime;
        tempICPairArr(i, 2) = info.ICCommPairArray(i).txMapping;
        tempICPairArr(i, 3) = info.ICCommPairArray(i).rxMapping;
        tempICPairArr(i, 4) = info.ICCommPairArray(i).txHandle;
        tempICPairArr(i, 5) = info.ICCommPairArray(i).rxHandle;
    end
    sortedICPairArr = sortrows(tempICPairArr, 1);
    priority = 1;
    for i = 1:numel(info.ICCommPairArray)
        blockHandle = sortedICPairArr(i, 4);
        set_param(blockHandle, 'Priority', num2str(priority));
        blockHandle = sortedICPairArr(i, 5);
        set_param(blockHandle, 'Priority', num2str(priority));
        priority = priority + 1;
    end
catch
    error('ERROR: setCommBlockPriorities failed!');
end

end

