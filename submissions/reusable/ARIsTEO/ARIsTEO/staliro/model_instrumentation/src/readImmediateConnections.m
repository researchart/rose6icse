% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = readImmediateConnections( infoIn )
%readImmediateConnections Generates connection matrix from immediate connections only.

info = infoIn;
try
    info.blocksGraph = createUnconnectedDiGraph(info.numOfBlocks); % All blocks
    info.ports = [];
    for i = 1:info.numOfBlocks
        portWidthList = [];
        portTypesList = [];
        try
            portWidthList = get_param(info.blockList{i}, 'CompiledPortWidths');
            portTypesList = get_param(info.blockList{i}, 'CompiledPortDataTypes');
            portDimensionsList = get_param(info.blockList(i), 'CompiledPortDimensions');
        catch
            if i ~= 1 % i = 1 is model itself
                fprintf('readImmediateConnections: Error in reading port info of %d\n', i);
                fprintf('   %s\n', info.blockList{i});
            end
        end
        try
            portsOfBlock = get_param(info.blockList{i}, 'PortConnectivity');
            for blockPortIndex = 1:length(portsOfBlock) % for each port
                if ~isempty(portsOfBlock(blockPortIndex, 1).DstBlock) % This is an output port
                    try
                        outPortIndex = str2double(portsOfBlock(blockPortIndex, 1).Type);
                        outPortPosition = portsOfBlock(blockPortIndex,1).Position;
                    catch
                        outPortIndex = 0;
                        outPortPosition = [0, 0];
                    end
                    if outPortIndex > 0
                        % --- Find Size Of Port ---
                        if ~isempty(portWidthList)
                            width = portWidthList.Outport(outPortIndex); % Read width of port
                        else
                            width = 1;
                        end
                        
                        if ~isempty(portTypesList)
                            % Determine size of data type
                            [dataSize, info.lookUpTable] = getSizeOfDataType(portTypesList.Outport{outPortIndex}, info.lookUpTable);
                        else
                            dataSize = 1;
                        end
                        edgeCost = width * dataSize; % Size of port = width * data size
                        
                        if ~isempty(portDimensionsList)
                            dimensions = portDimensionsList{1,1}.Outport((2*outPortIndex)-1:2*outPortIndex);
                        else
                            dimensions = [1, 1];
                        end
                        
                        %Add source port data
                        [ srcPortIndex, ~, info.ports ] = ...
                            addPortData( info.ports, i, 0, outPortIndex, edgeCost, portTypesList.Outport{outPortIndex}, dataSize, width, dimensions, outPortPosition);
                        
                        for blockDestination = 1:length(portsOfBlock(blockPortIndex,1).DstBlock) % for each destination of a port
                            dstBlockHandle = portsOfBlock(blockPortIndex,1).DstBlock(blockDestination);
                            dstPort = portsOfBlock(blockPortIndex,1).DstPort(blockDestination) + 1;
                            dstBlockIndex = getIndexFromHandle(dstBlockHandle, info.handles); % get index of destination
                            %Add connection to blocks graph
                            info.blocksGraph(i, dstBlockIndex) = edgeCost;

                            %Add connection to ports graph
                            portsOfDstBlock = get_param(dstBlockHandle, 'PortConnectivity');
                            portType = getPortTypeEnum(portsOfDstBlock(dstPort, 1).Type);
                            [ dstPortIndex, ~, info.ports ] = ...
                                addPortData( info.ports, dstBlockIndex, portType, dstPort, edgeCost, portTypesList.Outport{outPortIndex}, dataSize, width, dimensions, portsOfDstBlock(dstPort, 1).Position );
                            info.portsGraph(srcPortIndex, dstPortIndex) = 1;
                        end
                    end
                elseif ~isempty(portsOfBlock(blockPortIndex, 1).SrcBlock) %has incoming connection (can be input or action port)
                    portNo = str2double(portsOfBlock(blockPortIndex, 1).Type);
                    if portNo > 0 %Input port
                        [ srcPortIndex, ~, info.ports ] = getIndexOfPort( info.ports, i, 1, portNo);
                        switch lower(info.blockTypeList{i})
                            case 'outport' %Connect this port to related output port of its parent
                                [parentIndex, parentPortType, parentPortNo] = getRelatedPortOfParent(info, i);
                                if parentIndex > 0
                                    [ dstPortIndex, ~, info.ports ] = getIndexOfPort( info.ports, parentIndex, parentPortType, parentPortNo);
                                    info.portsGraph(srcPortIndex, dstPortIndex) = 1;
                                end
                            case 'goto' %Connect this port to output ports of corresponding Froms
                                froms = findCorrespondingFroms( info, i );
                                for fromIndex = froms
                                    [ dstPortIndex, ~, info.ports ] = getIndexOfPort( info.ports, fromIndex, 0, 1); %From blocks have only 1 output port
                                    info.portsGraph(srcPortIndex, dstPortIndex) = 1;
                                end
                            case 'subsystem'
                                [childIndex, childPortType, childPortNo] = getRelatedChildPortBlock(info, i, blockPortIndex);
                                if childIndex > 0
                                    [ dstPortIndex, ~, info.ports ] = getIndexOfPort( info.ports, childIndex, childPortType, childPortNo);
                                    info.portsGraph(srcPortIndex, dstPortIndex) = 1;
                                end
                        end
                    else %action type port
                        if strcmpi(portsOfBlock(blockPortIndex, 1).Type, 'Enable')
                            [ srcPortIndex, ~, info.ports ] = getIndexOfPort( info.ports, i, 3, blockPortIndex);
                        else
                            [ srcPortIndex, ~, info.ports ] = getIndexOfPort( info.ports, i, 2, blockPortIndex);
                        end
                        [childIndex, childPortType, childPortNo] = getRelatedChildPortBlock(info, i, blockPortIndex);
                        [ dstPortIndex, ~, info.ports ] = getIndexOfPort( info.ports, childIndex, childPortType, childPortNo);
                        info.portsGraph(srcPortIndex, dstPortIndex) = 2;
                        
                        srcPortIndex = dstPortIndex;
                        for j = 1:info.numOfBlocks
                            if info.parentIndices(j) == i
                                if strcmpi(info.blockTypeList{j}, 'Inport')
                                    [ dstPortIndex, ~, info.ports ] = getIndexOfPort( info.ports, j, 0, 1); %Inport blocks have only 1 output port
                                    info.portsGraph(srcPortIndex, dstPortIndex) = 2;
                                end
                            end
                        end
                    end
                end
            end
        catch
            if i ~= 1 % i = 1 is model itself
                fprintf('Could not read immediate connections of block %d: ', i);
                fprintf('%s\n', info.blockList{i});
            end
        end
    end
    
    %change portsGraph to n x n
    [numRows, numCols] = size(info.portsGraph);
    if numRows > numCols
        info.portsGraph(:, numCols + 1 : numRows) = 0;
    else
        if numRows < numCols
            info.portsGraph(numRows + 1 : numCols, :) = 0;
        end
    end
catch
    error('ERROR: readImmediateConnections failed!');
end
end
