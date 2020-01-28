% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [parentIndex, parentPortType, parentPortNo] = getRelatedPortOfParent(info, blockIndex)
%getRelatedPortOfParent For a 'Port' block, finds related port information of parent. 

try
    parentHandle = info.parentHandles(blockIndex);
    portsOfParent = get_param(parentHandle, 'PortConnectivity');
    switch info.blockTypeList{blockIndex}
        case 'Outport'
            portNo = get_param(info.handles(blockIndex), 'Port');
            for portIndex = 1:numel(portsOfParent)
                if ~isempty(portsOfParent(portIndex).DstBlock)
                    if strcmpi(portNo, portsOfParent(portIndex).Type)
                        parentIndex = getIndexFromHandle(parentHandle, info.handles);
                        parentPortType = 0; %Output port
                        parentPortNo = str2double(portNo);
                    end
                end
            end
        case 'Inport'
            portNo = get_param(info.handles(blockIndex), 'Port');
            for portIndex = 1:numel(portsOfParent)
                if ~isempty(portsOfParent(portIndex).SrcBlock)
                    if strcmpi(portNo, portsOfParent(portIndex).Type)
                        parentIndex = getIndexFromHandle(parentHandle, info.handles);
                        parentPortType = getPortTypeEnum(portsOfParent(portIndex).Type);
                        parentPortNo = portIndex;
                    end
                end
            end
        case 'ActionPort'
            for portIndex = 1:numel(portsOfParent)
                if strcmpi('ifaction', portsOfParent(portIndex).Type)
                    parentIndex = getIndexFromHandle(parentHandle, info.handles);
                    parentPortType = getPortTypeEnum(portsOfParent(portIndex).Type);
                    parentPortNo = portIndex;
                end
            end
        otherwise
            fprintf('! getRelatedPortOfParent: not handled port type\n');
            fprintf('%s\n', info.blockTypeList{blockIndex});
    end
catch
    if parentHandle == info.handles(1) %Port is input or output port of model.
        parentIndex = 0;
        parentPortType = -1;
        parentPortNo = 0;
    else
        error('ERROR: getRelatedPortOfParent failed!');
    end
end


end

