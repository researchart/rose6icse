% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ blockSpecialties ] = getBlockSpecialties(info)
%getBlockSpecialties Mark blocks with special cases.
% Special case codes:
%  Nothing special: 0
%  Delay introducing block: 1, 6(if it is also a while_for)
%  While_For subsystem: 2
%  Action subsystem: 3
%  ActionsOfIf_Switch: 4
%  Enable_Trigger_subsystem: 5

try
    blockSpecialties = cell(info.numOfBlocks, 1);
    for i = 1:info.numOfBlocks
        switch lower(info.blockTypeList{i})
            case 'triggerport'
                blockSpecialties{info.parentIndices(i)} = [blockSpecialties{info.parentIndices(i)}, 5];
            case 'enableport'
                blockSpecialties{info.parentIndices(i)} = [blockSpecialties{info.parentIndices(i)}, 5];
            case 'whileiterator'
                blockSpecialties{info.parentIndices(i)} = [blockSpecialties{info.parentIndices(i)}, 2];
            case 'foriterator'
                blockSpecialties{info.parentIndices(i)} = [blockSpecialties{info.parentIndices(i)}, 2];
            case {'if', 'switchcase'}
                destinations = find(info.blocksGraph(i, :));
                if numel(destinations) > 1 %Consider single destination if action blocks as 'Action' only
                    for j = destinations
                        if strcmpi(info.blockTypeList{j}, 'Subsystem')
                            blockSpecialties{j} = [blockSpecialties{j}, 4];
                        elseif strcmpi(info.blockTypeList{j}, 'Goto')
                            froms = findCorrespondingFroms(info, j);
                            fromDestinations = [];
                            for k = froms
                                fromDestinations = [fromDestinations, find(info.blocksGraph(k, :))];
                            end
                            for k = fromDestinations
                                if strcmpi(info.blockTypeList{k}, 'Subsystem')
                                    blockSpecialties{k} = [blockSpecialties{k}, 4];
                                else
                                    fprintf('WARNING !!! destination of if block (%d), %d is not subsystem. Tool does not support multiple goto-from for if-action\n', i, j);
                                end
                            end
                        else
                            fprintf('WARNING !!! destination of if block (%d), %d is not subsystem\n', i, j);
                        end
                    end
                end
        end
    end
    tempInfo = info;
    tempInfo.blockSpecialties = blockSpecialties;
    for i = 1:info.numOfBlocks
        if isDelayIntroducing(info.blockTypeList{i})
            if ~checkIfBlockIsInWhile(tempInfo, i)
                for j = info.ancestorsList{i}
                    if isempty(find(blockSpecialties{j} == 1, 1))
                        blockSpecialties{j} = [blockSpecialties{j}, 1];
                    end
                end
            else
                for j = info.ancestorsList{i}
                    if isempty(find(blockSpecialties{j} == 6, 1))
                        blockSpecialties{j} = [blockSpecialties{j}, 6];
                    end
                end
            end
        end
    end
    
    %Now mark the action blocks that are not part of an if-action or switch-case
    for i = 1:info.numOfBlocks
        if strcmpi(info.blockTypeList{i}, 'ActionPort')
            j = info.parentIndices(i);
            if isempty(find(blockSpecialties{j} == 4, 1)) %not ActionsOfIf_Switch
                blockSpecialties{info.parentIndices(j)} = [blockSpecialties{info.parentIndices(j)}, 3];
            end
        end
    end
    
    %Mark rest as 'nothing special'
    for i = 1:info.numOfBlocks
        if isempty(blockSpecialties{i})
            blockSpecialties{i} = 0;
        end
    end
catch
    error('ERROR: getBlockSpecialties failed!');
end

end

