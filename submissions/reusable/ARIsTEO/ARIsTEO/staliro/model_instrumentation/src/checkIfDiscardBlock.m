% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ discardBlock ] = checkIfDiscardBlock( info, blockIndex )
%checkIfDiscardBlock Check if this block should be discarded.
%Blocks discarded:
% 1. Blocks inside a while or for loop
% 2. DataStoreMemory blocks
% 3. Goto blocks (corresponding Froms are discarded in an higher level function)
% 4. Outport or Inport but not in an action nor In/Out of model itself
% 5. parent does not contain delay & block depth is more than desired Depth
% 6. 'Subsystem' blocks for which blocks inside it are not discarded. (Not deep, while/for)

try
    discardBlock = 0;
    if checkIfBlockIsInWhile(info, blockIndex) %(1)
        discardBlock = 1;
    elseif strcmpi(info.blockTypeList{blockIndex}, 'DataStoreMemory') %(2)
        discardBlock = 1;
    elseif strcmpi(info.blockTypeList{blockIndex}, 'Goto') %(3)
        discardBlock = 1;
    else
        if (strcmpi(info.blockTypeList{blockIndex}, 'Outport') || strcmpi(info.blockTypeList{blockIndex}, 'Inport'))...
            && ~(checkIfBlockIsInAction(info, blockIndex) || info.parentIndices(blockIndex) == 1) %(4) Outport or Inport but not in an action nor In/Out of model itself
            discardBlock = 1;
        end
        if isempty(find(info.blockSpecialties{info.parentIndices(blockIndex)} == 1, 1)) ...
                && info.blockDepths(blockIndex) > info.desiredDepth %(5) parent does not contain delay & block depth is more than desired Depth
            discardBlock = 1;
        end
        if strcmpi(info.blockTypeList{blockIndex}, 'Subsystem')
            if isempty(find(info.blockSpecialties{blockIndex} == 2, 1)) %not while or for
                if ~isempty(find(info.blockSpecialties{blockIndex} == 1, 1)) ...
                    || info.blockDepths(blockIndex) < info.desiredDepth %(6)
                    discardBlock = 1;
                end
            end
        end
%         if info.blockDepths(blockIndex) > info.desiredDepth && discardBlock == 0
%             fprintf('Block %d - %s depth is %d but not discarded - %d.\n', blockIndex, info.blockList{blockIndex}, info.blockDepths(blockIndex), isempty(find(info.blockSpecialties{info.parentIndices(blockIndex)} == 1, 1)));
%         end
    end
catch
    error('ERROR: checkIfDiscardBlock failed!');
end
end

