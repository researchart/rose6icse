% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [index, type, portNumber] = getRelatedChildPortBlock(info, blockIndex, blockPortIndex)
%getRelatedChildPortBlock Searches in the children of the block and returns
%the port information of related Inport/Outport block.

try
    index = 0;
    type = -1;
    portNumber = 0;
                
    portsOfBlock = get_param(info.blockList{blockIndex}, 'PortConnectivity');
    children = checkIfBlockIsAParent(info.handles(blockIndex), info.parentHandles);
    if ~isempty(portsOfBlock(blockPortIndex).DstBlock)
        portNo = str2double(portsOfBlock(blockPortIndex).Type);
        if portNo > 0
            portType = 'Outport';
            portTypeEnum = 1; %A block of type 'Outport' has a single 'input' port.
        end
    elseif ~isempty(portsOfBlock(blockPortIndex).SrcBlock)
        portNo = str2double(portsOfBlock(blockPortIndex).Type);
        if portNo > 0
            portType = 'Inport';
            portTypeEnum = 0; %A block of type 'Inport' has a single 'output' port.
        elseif strcmpi(portsOfBlock(blockPortIndex).Type, 'ifaction')
            portType = 'ActionPort';
            portTypeEnum = 1; %we assume action port has  single input port
            portNo = 1;
        end
    else
        fprintf('getRelatedChildPortBlock: unhandled port type block: %d, port: %d\n', blockIndex, blockPortIndex);
    end
    for childIndex = children
        if strcmpi(info.blockTypeList{childIndex}, portType)
            if strcmpi(portType, 'Inport') || strcmpi(portType, 'Outport')
                if portNo == str2double(get_param(info.handles(childIndex), 'Port'))
                    index = childIndex;
                    type = portTypeEnum;
                    portNumber = 1;
                end
            else
                index = childIndex;
                type = portTypeEnum;
                portNumber = 1;
            end
        end
    end
catch
    error('ERROR: getRelatedChildPortBlock failed!');
end

end

