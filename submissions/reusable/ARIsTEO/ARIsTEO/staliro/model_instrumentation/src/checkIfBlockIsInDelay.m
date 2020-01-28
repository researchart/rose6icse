% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ blockIsInDelay ] = checkIfBlockIsInDelay(info, blockIndex)
%checkIfBlockIsInDelay Check if any of the ancestors contains a delay.

blockIsInDelay = 0;
try
    for i = info.ancestorsList{blockIndex}
        if i > 0
            if ~isempty(find(info.blockSpecialties{i} == 1, 1))
                blockIsInDelay = 1;
                break;
            end
        end
    end
catch
    error('ERROR: checkIfBlockIsInAction failed !');
end
end

