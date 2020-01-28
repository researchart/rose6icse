% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ parentHandles ] = readParentHandles( blockList )
%readParentHandles Array of handle of parent of each block

try
parentHandles = -1 * ones(numel(blockList), 1); % Keeps handles of parents of blocks

for i = 1:numel(blockList)
    try
        parentHandles(i) = get_param(get_param(blockList{i}, 'Parent'), 'Handle');
    catch
        if i ~= 1 % It is normal for block 1 (model itself) to not have a parent
            fprintf('!!! Could not read parent of block %d: ', i);
            fprintf('%s\n', blockList{i});
        end
    end
end
catch
    error('ERROR: readParentHandles failed!');
end
end

