% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ isSuccess ] = addTimeMeasureBlocks( info, blockId, sFuncBlockNo )
%addTimeMeasureBlocks Adds start and finish time measurements for all 
%blocks inside mergedBlockId.

isSuccess = 0;
try
    blockHandle = info.handles(blockId);
    blockParent = get_param(blockHandle, 'Parent');
    blockName = get_param(blockHandle, 'Name');
    blockPosition = get_param(blockHandle, 'Position'); %left, top, right, bottom
    portsOfBlock = get_param(blockHandle, 'PortConnectivity');

    inputPorts = [];
    outputPorts = [];
    actionPorts = [];
    for i = 1:numel(info.ports)
        if info.ports(i).block == blockId
            if info.ports(i).type == 1
                inputPorts = [inputPorts, i];
            elseif info.ports(i).type == 0
                actionTypeDest = 0;
                dests = find(info.portsGraph(i, :));
                for j = dests
                    if info.ports(j).type > 1
                        actionTypeDest = 1;
                        break;
                    end
                end
                if ~actionTypeDest % we cannot replace line to an action port with s-function
                    outputPorts = [outputPorts, i];
                end
            else
                actionPorts = [actionPorts, i];
            end
        end
    end
    
    if numel(actionPorts) > 0
        fprintf('block %d has action port. Measure time not supported\n', blockId);
        return;
    end
    if numel(inputPorts) == 0
        fprintf('block %d has no input port. Measure time not supported\n', blockId);
        return;
    end
    if numel(outputPorts) == 0
        fprintf('block %d has no output port. Measure time not supported\n', blockId);
        return;
    end
    
    %Add start time measure s-function block - width of sfunc block + 30,
    %distance between blocks = 20
    sFuncBlockPosition = [blockPosition(1) - 50, blockPosition(2), blockPosition(1) - 20, blockPosition(4)];
    sFuncHandle = add_block('ASUCPSLabExecutionTime/ExecTimeMeasureStart', [blockParent, sprintf('/TimeMeasureStart%d', sFuncBlockNo)],...
        'Position', sFuncBlockPosition, 'blockID', sprintf('%d', sFuncBlockNo), 'numOfPorts', sprintf('%d', numel(inputPorts)));
    startSFuncName = get_param(sFuncHandle, 'Name');
    blockHandle = [blockHandle, sFuncHandle];
    
    %Add finish time measure s-function block
    sFuncBlockPosition = [blockPosition(3) + 20, blockPosition(2), blockPosition(3) + 50, blockPosition(4)];
    sFuncHandle = add_block('ASUCPSLabExecutionTime/ExecTimeMeasureFinish', [blockParent, sprintf('/TimeMeasureFinish%d', sFuncBlockNo)],...
        'Position', sFuncBlockPosition, 'blockID', sprintf('%d', sFuncBlockNo), 'numOfPorts', sprintf('%d', numel(outputPorts)));
    finishSFuncName = get_param(sFuncHandle, 'Name');
    blockHandle = [blockHandle, sFuncHandle];
    
    for blockPortIndex = 1:length(portsOfBlock) % for each port
        if ~isempty(portsOfBlock(blockPortIndex, 1).DstBlock) % This is an output port
            portNo = str2double(portsOfBlock(blockPortIndex, 1).Type);
            addedLineForThisPort = 0;
            for blockDestination = 1:numel(portsOfBlock(blockPortIndex,1).DstBlock)
                dstBlockHandle = portsOfBlock(blockPortIndex,1).DstBlock(blockDestination);
                dstBlockName = get_param(dstBlockHandle, 'Name');
                dstPortNo = portsOfBlock(blockPortIndex,1).DstPort(blockDestination) + 1;

                delete_line(blockParent, sprintf('%s/%d', blockName, portNo), sprintf('%s/%d', dstBlockName, dstPortNo));
                if ~addedLineForThisPort %For multiple destinations, we 
                    add_line(blockParent, sprintf('%s/%d', blockName, portNo), sprintf('%s/%d', finishSFuncName, portNo), 'autorouting', 'on');
                    addedLineForThisPort = 1;
                end
                add_line(blockParent, sprintf('%s/%d', finishSFuncName, portNo), sprintf('%s/%d', dstBlockName, dstPortNo), 'autorouting', 'on');
            end
        elseif ~isempty(portsOfBlock(blockPortIndex, 1).SrcBlock)
            portNo = str2double(portsOfBlock(blockPortIndex, 1).Type);
            if portNo > 0 %Input port
                for blockDestination = 1:numel(portsOfBlock(blockPortIndex,1).SrcBlock)
                    incomingBlockHandle = portsOfBlock(blockPortIndex,1).SrcBlock(blockDestination);
                    incomingBlockName = get_param(incomingBlockHandle, 'Name');
                    incomingPortNo = portsOfBlock(blockPortIndex,1).SrcPort(blockDestination) + 1;

                    delete_line(blockParent, sprintf('%s/%d', incomingBlockName, incomingPortNo), sprintf('%s/%d', blockName, portNo));
                    add_line(blockParent, sprintf('%s/%d', startSFuncName, portNo), sprintf('%s/%d', blockName, portNo), 'autorouting', 'on');
                    add_line(blockParent, sprintf('%s/%d', incomingBlockName, incomingPortNo), sprintf('%s/%d', startSFuncName, portNo), 'autorouting', 'on');
                end
            else %action port
            end
        end
    end

    Simulink.BlockDiagram.createSubSystem(blockHandle);
    isSuccess = 1;
catch
    error('ERROR: addTimeMeasureBlocks failed!');
end

end

