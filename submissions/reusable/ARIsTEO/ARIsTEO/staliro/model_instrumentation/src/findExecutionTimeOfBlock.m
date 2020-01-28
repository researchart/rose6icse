% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ execTime ] = findExecutionTimeOfBlock( newInfo, blockIndex, portIndex )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
isIcBlock = 0;
blockName = get_param(newInfo.handles(blockIndex), 'Name');
if length(blockName) > 8
    if strcmpi(blockName(1:8), 'ICSender') || strcmpi(blockName(1:8), 'ICReceiv')
        isIcBlock = 1;
    end
end
children = checkIfBlockIsAParent(newInfo.handles(blockIndex), newInfo.parentHandles);
if ~isempty(children) && ~isIcBlock
    execTime = [];
    for i = children
        blockType = newInfo.blockTypeList{i};
        if strcmpi(blockType, 'Outport')
            if str2double(get_param(newInfo.handles(i), 'Port')) == (portIndex + 1)
                execTime = [execTime, findExecutionTimeOfBlock(newInfo, i, 1)];
            end
        end
    end
else
    if newInfo.startTimeOfBlocks(blockIndex) > 0
        execTime = newInfo.startTimeOfBlocks(blockIndex) + newInfo.wcetOfBlocks(blockIndex);
    else
        blockType = newInfo.blockTypeList{blockIndex};
        if strcmpi(blockType, 'Inport')
            portNo = str2double(get_param(newInfo.handles(blockIndex), 'Port'));
            portsOfBlock = get_param(newInfo.parentHandles(blockIndex), 'PortConnectivity');
            execTime = findExecutionTimeOfBlock(newInfo, getIndexFromHandle(portsOfBlock(portNo).SrcBlock(1), newInfo.handles), portsOfBlock(portNo).SrcPort(1));
        elseif strcmpi(blockType, 'From')
            fromTag = cellstr(get_param(newInfo.blockList{blockIndex}, 'GotoTag'));
            fromParent = newInfo.parentHandles(blockIndex);
            for j = 2:numOfAllblocks % searching corresponding From
                if strcmpi(newInfo.blockTypeList{j}, 'Goto') % fromIndex is a From
                    gotoVisibility = get_param(newInfo.blockList{j}, 'TagVisibility');
                    gotoTag = cellstr(get_param(newInfo.blockList{j}, 'GotoTag'));
                    if strcmpi(gotoTag, fromTag) % This is a corresponsing "Goto"
                        gotoParent = newInfo.parentHandles(j);
                        if strcmpi(gotoVisibility, 'global') == 1 || gotoParent == fromParent % if goto tag visibility is local, then only 'From' tags in same subsystem receives data.
                            execTime = findExecutionTimeOfBlock(newInfo, j, 1);
                        end
                    end
                end
            end
        else
            portsOfBlock = get_param(newInfo.handles(blockIndex), 'PortConnectivity');
            execTime = [];
            for i = 1:length(portsOfBlock)
                if ~isempty(portsOfBlock(i).SrcBlock)
                    execTime = [execTime, findExecutionTimeOfBlock(newInfo, getIndexFromHandle(portsOfBlock(i).SrcBlock(1), newInfo.handles), portsOfBlock(i).SrcPort(1))];
                end
            end
        end
    end
end
end

