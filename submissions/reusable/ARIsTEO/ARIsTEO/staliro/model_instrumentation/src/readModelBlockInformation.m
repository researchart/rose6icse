% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [blockList, wasModelOpenedAlready] = readModelBlockInformation(modelName, modelDepth)
% If model is open, get info. If model is not open, first load it.

% Turn off warnings that can arise from model to be opened/loaded
warning('off');
try
    if modelDepth == -1 % -1 = all depth
        %blockList = find_in_models(modelName, 'FollowLinks', 'on', 'LookUnderMasks', 'all');
        blockList = find_system( modelName, 'FollowLinks', 'on', 'LookUnderMasks', 'all' );
    else
        blockList = find_system( modelName, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'SearchDepth', modelDepth );
    end
    wasModelOpenedAlready = 1;
catch
    fprintf('\nModel ''%s'' is not open. Trying to load model.\n', modelName);
    wasModelOpenedAlready = 0;
    load_system(modelName);
    if modelDepth == -1 % -1 = all depth
        blockList = find_system( modelName, 'FollowLinks', 'on', 'LookUnderMasks', 'all' );
    else
        blockList = find_system( modelName, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'SearchDepth', modelDepth );
    end
end
end