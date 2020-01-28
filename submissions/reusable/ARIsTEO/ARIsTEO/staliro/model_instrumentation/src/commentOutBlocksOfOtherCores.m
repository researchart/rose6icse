% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ ] = commentOutBlocksOfOtherCores( modelName, excludingCore )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[blockList, wasModelOpenedAlready] = readModelBlockInformation(modelName, -1);

for i = 2:length(blockList)
    userData = get_param(blockList{i}, 'UserData');
    if ~isempty(userData)
        if isfield(userData, 'mapping')
            if userData.mapping ~= excludingCore && userData.mapping ~= 0
                try
                    set_param(blockList{i}, 'Commented', 'on');
                catch
                    %fprintf('Could not comment out %s. Deleting...\n', blockList{i});
                    try
                        delete_block(blockList{i});
                    catch
                        fprintf('Could not delete %s !!!\n', blockList{i});
                    end
                end
            end
        end
    end
end
end

