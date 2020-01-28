% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ blockIsInAction ] = checkIfBlockIsInAction(info, blockIndex)
%checkIfBlockIsInAction Check if the block is inside an action subsystem.

blockIsInAction = 0;
try
    for i = info.ancestorsList{blockIndex}
        if i > 0
            if ~isempty(find(info.blockSpecialties{i} == 3, 1)) ...
                    || ~isempty(find(info.blockSpecialties{i} == 5, 1))%one of the ancestors is action or enable
                blockIsInAction = 1;
                break;
            end
        end
    end
catch
    error('ERROR: checkIfBlockIsInAction failed !');
end
end

