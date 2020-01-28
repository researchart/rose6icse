% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ froms ] = findCorrespondingFroms( info, blockIndex )
%findCorrespondingFroms Return indices of corresponding 'From' blocks in array

try
    froms = [];
    gotoTag = cellstr(get_param(info.blockList{blockIndex}, 'GotoTag'));
    gotoVisibility = get_param(info.blockList{blockIndex}, 'TagVisibility');
    gotoParent = info.parentHandles(blockIndex);
    for fromIndex = 2:length(info.blockList) % searching in all blocks
        if strcmpi(info.blockTypeList{fromIndex}, 'From') % fromIndex is a From
            fromTag = cellstr(get_param(info.blockList{fromIndex}, 'GotoTag'));
            if strcmpi(gotoTag, fromTag) % This is a "From" with same tag
                fromParent = info.parentHandles(fromIndex);
                if strcmpi(gotoVisibility, 'global') == 1 || gotoParent == fromParent % if goto tag visibility is local, then only from tags in same subsystem receives data.
                    froms = [froms, fromIndex];
                end
            end
        end
    end
catch
    error('ERROR: findRelatedFroms failed!\n');
end

end

