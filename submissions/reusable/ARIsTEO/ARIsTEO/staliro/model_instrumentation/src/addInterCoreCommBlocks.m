% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function info = addInterCoreCommBlocks( infoIn, config )
%addInterCoreCommBlocks add InterCore Comm Blocks between blocks of different cores.

try
    info = infoIn;
    info.ICCommPairArray = [];
    
    %Physical dimensions
    sFuncBlockWidth = 20;
    sFuncBlockHalfHeight = 5;
    sFuncDistBetweenBlocks = 10;
    
    %Initializations from config
    bufferID = 0;
    currentAddress = zeros(numel(config.startAddresses), 1);
    lastAddress = zeros(numel(config.endAddresses), 1);
    currentAddressRegion = 1;
    for i = 1:numel(config.startAddresses)
        availableSpace = hex2dec(config.endAddresses{i}) - hex2dec(config.startAddresses{i});
        if availableSpace < 0
            fprintf('WARNING!!! Incorrect config file. Check start - end addresses !\n');
        end
        currentAddress(i) = idivide(hex2dec(config.startAddresses{i}), int32(config.alignmentSize), 'ceil');
        currentAddress(i) = currentAddress(i) * int32(config.alignmentSize);
        lastAddress(i) = idivide(hex2dec(config.endAddresses{i}), int32(config.alignmentSize));
        lastAddress(i) = lastAddress(i) * int32(config.alignmentSize);
    end
    
    
    %Check destination of each port
    for i = 1:numel(info.ports)
        if info.ports(i).type == 0 %output port
            portMapping = info.blockMappingList{info.ports(i).block};
            if numel(portMapping) ~= 1 %If mapping is not certain, get mapping of predecessor port (for output ports)
                pred = find(info.portsGraph(:, i));
                if numel(pred) == 1
                    portMapping = info.blockMappingList{info.ports(pred).block};
                    if numel(portMapping) ~= 1
                        fprintf('WARNING! addInterCoreCommBlocks: unexpected port mapping\n');
                    end
                else
                    fprintf('WARNING! addInterCoreCommBlocks: unexpected connection in portsGraph\n');
                end
            end
            
            %Find destinations ports which are mapped to an other core
            portDestinations = find(info.portsGraph(i, :));
            dstPortsOnCores = cell(info.numOfProc, 0);
            dstPortsOnCores{info.numOfProc} = [];
            for j = portDestinations
                dstMapping = info.blockMappingList{info.ports(j).block};
                if numel(dstMapping) ~= 1 %If mapping is not certain, get mapping of successor port (for input ports)
                    if info.ports(j).type == 1 %input
                        succ = find(info.portsGraph(j, :));
                        if numel(succ) == 1
                            dstMapping = info.blockMappingList{info.ports(succ).block};
                            if numel(dstMapping) ~= 1
                                fprintf('WARNING! addInterCoreCommBlocks: unexpected dst port mapping\n');
                            end
                        else
                            fprintf('WARNING! addInterCoreCommBlocks: unexpected dst connection in portsGraph\n');
                        end
                    else %for non-input ports (like action or enable etc.)
                        dstMapping = portMapping;
                    end
                end
                
                dstPortsOnCores{dstMapping} = [dstPortsOnCores{dstMapping}, j];
            end
            
            for p = 1:info.numOfProc
                if p ~= portMapping
                    if ~isempty(dstPortsOnCores{p})
                        %There are destination ports which are mapped to core p
                        %Add an IC communication pair for target core
                        
                        %src block/port information
                        srcBlockIndex = info.ports(i).block;
                        srcHandle = get_param(info.blockList{srcBlockIndex}, 'Handle');
                        srcBlockParent = get_param(srcHandle, 'Parent');
                        srcBlockName = get_param(srcHandle, 'Name');
                        srcOutPortNo = info.ports(i).portNo;
                        dataReadyTime = info.ports(i).dataReadyTime;
                        
                        dataSize = info.ports(i).dataSize;
                        portDims = info.ports(i).dimensions;
                        bufferSize = int32(portDims(1)*portDims(2)*dataSize);
                        try
                            srcPortPosition = info.ports(i).position;
                        catch
                            srcPortPosition = get_param(info.blockList{srcBlockIndex}, 'Position');
                        end
                        
                        %Search for available memory for the semaphore.
                        firstCheckedAddressRegion = currentAddressRegion;
                        while (lastAddress(currentAddressRegion) - currentAddress(currentAddressRegion)) < config.semaphoreSize
                            if currentAddressRegion < numel(lastAddress)
                                currentAddressRegion = currentAddressRegion + 1;
                            else
                                currentAddressRegion = 1;
                            end
                            if currentAddressRegion == firstCheckedAddressRegion %looped to beginning
                                fprintf('WARNING !!! No more memory available for placement of semaphore (%d).\n', bufferID);
                                break;
                            end
                        end
                        semaphoreAddressInt = currentAddress(currentAddressRegion);
                        currentAddress(currentAddressRegion) = currentAddress(currentAddressRegion) + config.semaphoreSize;
                        currentAddress(currentAddressRegion) = idivide(currentAddress(currentAddressRegion), int32(config.alignmentSize), 'ceil');
                        currentAddress(currentAddressRegion) = currentAddress(currentAddressRegion) * int32(config.alignmentSize);
                        
                        %Search for available memory for the buffer.
                        while (lastAddress(currentAddressRegion) - currentAddress(currentAddressRegion)) < bufferSize
                            if currentAddressRegion < numel(availableSpace)
                                currentAddressRegion = currentAddressRegion + 1;
                            else
                                currentAddressRegion = 1;
                            end
                            if currentAddressRegion == firstCheckedAddressRegion %looped to the beginning
                                fprintf('WARNING !!! No more memory available for buffer (%d) placement.\n', bufferID);
                                break;
                            end
                        end
                        bufferAddressInt = currentAddress(currentAddressRegion);
                        currentAddress(currentAddressRegion) = currentAddress(currentAddressRegion) + bufferSize;
                        currentAddress(currentAddressRegion) = idivide(currentAddress(currentAddressRegion), int32(config.alignmentSize), 'ceil');
                        currentAddress(currentAddressRegion) = currentAddress(currentAddressRegion) * int32(config.alignmentSize);
                        
                        %Delete lines to destinations
                        for j = dstPortsOnCores{p}
                            dstInPortNo = info.ports(j).portNo;
                            dstHandle = get_param(info.blockList{info.ports(j).block}, 'Handle');
                            dstBlockName = get_param(dstHandle, 'Name');
                            delete_line(srcBlockParent, sprintf('%s/%d', srcBlockName, srcOutPortNo), sprintf('%s/%d', dstBlockName, dstInPortNo));
                        end
                        
                        % Now we will add S-Function blocks for inter core communications
                        x_bar = srcPortPosition(1) + sFuncDistBetweenBlocks;
                        y_bar = srcPortPosition(2) - sFuncBlockHalfHeight;
                        newBlockPosition = [x_bar, y_bar, x_bar + sFuncBlockWidth, y_bar + 2*sFuncBlockHalfHeight];
                        txHandle = add_block('ASUCPSLabMultiCore/InterCoreSenderSystem', [srcBlockParent, sprintf('/ICSender%d', bufferID)], 'Position', newBlockPosition, 'icSendBufID', sprintf('%d', bufferID));
                        set_param(txHandle, 'icSendColumnDim', sprintf('%d', portDims(1)), 'icSendRowDim', sprintf('%d', portDims(2)), 'icSendDataSize', sprintf('%d', dataSize));
                        if iscell(info.sampleTimeList{srcBlockIndex}) % Rate transitions blocks have more than 1 sample time
                            tempSampleTime = info.sampleTimeList{getIndexFromHandle(dstHandle, info.handles)}(1)/1000000;
                        else
                            tempSampleTime = info.sampleTimeList{srcBlockIndex}(1)/1000000;
                        end
                        set_param(txHandle, 'icSendSampleTime', sprintf('%f', tempSampleTime), 'icSendCoreID', sprintf('%d', portMapping), 'icSendBufAddr', sprintf('0x%s', dec2hex(bufferAddressInt)));
                        set_param(txHandle, 'icSendSemAddr', sprintf('0x%s', dec2hex(semaphoreAddressInt)));
                        setMappingOfBlock( txHandle, portMapping );
                        add_line(srcBlockParent, sprintf('%s/%d', srcBlockName, srcOutPortNo), sprintf('%s/1', get_param(txHandle, 'Name')), 'autorouting', 'on');
                        
                        x_bar = x_bar + sFuncBlockWidth + sFuncDistBetweenBlocks;
                        newBlockPosition = [x_bar, y_bar, x_bar + sFuncBlockWidth, y_bar + 2*sFuncBlockHalfHeight];
                        rxHandle = add_block('ASUCPSLabMultiCore/InterCoreReceiverSystem', [srcBlockParent, sprintf('/ICReceiver%d', bufferID)], 'Position', newBlockPosition, 'icRcvBufID', sprintf('%d', bufferID));
                        set_param(rxHandle, 'icRcvColumnDim', sprintf('%d', portDims(1)), 'icRcvRowDim', sprintf('%d', portDims(2)), 'icRcvDataSize', sprintf('%d', dataSize));
                        set_param(rxHandle, 'icRcvSampleTime', sprintf('%f', tempSampleTime), 'icRcvCoreID', sprintf('%d', p), 'icRcvBufAddr', sprintf('0x%s', dec2hex(bufferAddressInt)));
                        set_param(rxHandle, 'icRcvSemAddr', sprintf('0x%s', dec2hex(semaphoreAddressInt)));
                        setMappingOfBlock( rxHandle, p );
                        rxBlockName = get_param(rxHandle, 'Name');
                        
                        %Keep IC Comm pair information in an array
                        bufferArrayIndex = bufferID + 1; %bufferId starts from 0
                        info.ICCommPairArray(bufferArrayIndex).dataReadyTime = dataReadyTime;
                        info.ICCommPairArray(bufferArrayIndex).txMapping = portMapping;
                        info.ICCommPairArray(bufferArrayIndex).rxMapping = p;
                        info.ICCommPairArray(bufferArrayIndex).txHandle = txHandle;
                        info.ICCommPairArray(bufferArrayIndex).rxHandle = rxHandle;
                        
                        %Add lines to destinations
                        for j = dstPortsOnCores{p}
                            dstInPortNo = info.ports(j).portNo;
                            dstHandle = get_param(info.blockList{info.ports(j).block}, 'Handle');
                            dstBlockName = get_param(dstHandle, 'Name');
                            add_line(srcBlockParent, sprintf('%s/1', rxBlockName), sprintf('%s/%d', dstBlockName, dstInPortNo), 'autorouting', 'on');
                        end
                        
                        %increment buffer id for next IC comm pair
                        bufferID = bufferID + 1;
                        fprintf('.');
                    end
                end
            end
        end
    end
    fprintf('\n'); %We put . for every ICComm pair above and now need to start new line.
catch
    error('ERROR: addInterCoreCommBlocks failed!');
end

end

