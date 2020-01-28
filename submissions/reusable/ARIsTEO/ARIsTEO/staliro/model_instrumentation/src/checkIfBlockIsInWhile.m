% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ blockIsInWhile ] = checkIfBlockIsInWhile(info, blockIndex)
%checkIfBlockIsInWhile Check if the block is inside a while subsystem.

blockIsInWhile = 0;
try
    for i = info.ancestorsList{blockIndex}
        if i > 0
            if ~isempty(find(info.blockSpecialties{i} == 2, 1)) %one of the ancestors is while
                blockIsInWhile = 1;
                break;
            end
        end
    end
catch
    error('ERROR: checkIfBlockIsInWhile failed !');
end
end

