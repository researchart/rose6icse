% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ handleArr ] = readBlockHandles( blockList )
%readBlockHandles readBlockHandles
% List of handle of each block

try
    handleArr = zeros(numel(blockList), 1);
    for i = 1:length(blockList)
        handleArr(i) = get_param(blockList{i}, 'Handle');
    end
catch
    error('ERROR: readBlockHandles failed!');
end
end
