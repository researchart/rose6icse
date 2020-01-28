% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ mappingOfBlocks ] = readBlockMappings( blockList )
%readBlockTypes List of strings of block types of each block

mappingOfBlocks = -2 * ones(1, length(blockList));
mappingOfBlocks(1) = 0; %Model itself mapped to all cores
for i = 2:length(blockList)
    try
        userData = get_param(blockList{i}, 'UserData');
        if isfield(userData, 'mapping')
            mappingOfBlocks(i) = userData.mapping;
        end
    catch
         mappingOfBlocks(i) = -2;
         fprintf('!!! Could not read mapping of %d-%s\n', i, blockList{i})
    end
end

end

