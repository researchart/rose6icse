% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ blockTypeList ] = readBlockTypes( blockList )
%readBlockTypes List of strings of block types of each block

try
    numOfBlocks = numel(blockList);
    blockTypeList = cell(numOfBlocks, 1); % Keeps types of blocks as strings
    for i = 1:numOfBlocks
        try
            blockTypeList{i} = get_param(blockList{i}, 'BlockType');
            if strcmpi(blockTypeList{i}, 'Subsystem')
                isVirtual = get_param(blockList{i}, 'IsSubsystemVirtual');
                if strcmpi(isVirtual, 'off')
                    fprintf('%d - %s is nonVirtual\n', i, blockList{i});
                end
                isAtomic = get_param(blockList{i}, 'TreatAsAtomicUnit');
                if strcmpi(isAtomic, 'on')
                    fprintf('%d - %s is ATOMIC\n', i, blockList{i});
                end
            end
        catch
            blockTypeList{i} = 'none';
            if i ~= 1 % i = 1 is model itself
                fprintf('Could not read block type of block %d: ', i);
                fprintf('%s\n', blockList{i});
            end
        end
    end
catch
    error('ERROR: readBlockTypes failed!');
end
end

