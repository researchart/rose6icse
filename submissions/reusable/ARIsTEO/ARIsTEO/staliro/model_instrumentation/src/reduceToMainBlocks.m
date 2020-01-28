% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = reduceToMainBlocks( infoIn )
%reduceToMainBlocks Discard trivial blocks (Flatten the model)

try
    info = infoIn;
    
    info.mainBlocksGraph = info.blocksGraph;
    info.mainBlockIndices = cell(info.numOfBlocks, 1);
    for i = 1:info.numOfBlocks
        info.mainBlockIndices{i} = i;
    end
    directRemoveBlocks = 1; %Firstly, remove the block representing the model itself.
    for i = 2:info.numOfBlocks
        if checkIfBlockIsInWhile(info, i)
            directRemoveBlocks = [directRemoveBlocks, i];
        elseif strcmpi(info.blockTypeList{i}, 'DataStoreMemory')
            directRemoveBlocks = [directRemoveBlocks, i];
        elseif strcmpi(info.blockTypeList{i}, 'Goto')
            if isempty(find(directRemoveBlocks == i, 1))
                %First change connections
                srcs = find(info.mainBlocksGraph(:, i) ~= 0);
				srcs = srcs.'; %transpose for getting a 1 by n matrix
                froms = findCorrespondingFroms(info, i);
                dsts = [];
                for j = froms
                    dsts = [dsts, find(info.mainBlocksGraph(j, :) ~= 0)];
                end
                for j = srcs
                    for k = dsts
                        info.mainBlocksGraph(j, k) = info.mainBlocksGraph(j, i);
                    end
                end
                %Then add these goto and from blocks to remove list
                directRemoveBlocks = [directRemoveBlocks, i];
                directRemoveBlocks = [directRemoveBlocks, froms];
            end
        elseif strcmpi(info.blockTypeList{i}, 'Subsystem') && isempty(find(info.blockSpecialties{i} == 2, 1))
            if isempty(find(directRemoveBlocks == i, 1))
                %Subsystem but not 'while subsystem'. 
                p = 0;
                portType = 0;
                while 1
                    p = p + 1;
                    [ portIndex, existingPort, ~ ] = getIndexOfPort( info.ports, i, portType, p );
                    if existingPort
                        srcs = find(info.portsGraph(:, portIndex));
						srcs = srcs.';
                        dsts = find(info.portsGraph(portIndex, :));
                        for j = srcs
                            srcBlockIndex = info.ports(j).block;
                            edgeCost = info.ports(j).edgeCost;
                            if edgeCost < 1
                                fprintf('WARNING !!! edgeCost of port %d is %d\n', j, edgeCost);
                            end
                            for k = dsts
                                dstBlockIndex = info.ports(k).block;
                                info.mainBlocksGraph(srcBlockIndex, dstBlockIndex) = edgeCost;
                            end
                        end
                    else
                        if portType == 0 % done searching output ports, not search input ports
                            portType = 1;
                            p = 0;
                        else % done searching input ports, exit
                            break;
                        end
                    end
                end
                directRemoveBlocks = [directRemoveBlocks, i]; %Remove the parent block
            end
        end
    end
    %Inport and outport blocks of removed subsystems
    for i = 1:info.numOfBlocks
        if ~checkIfBlockIsInWhile(info, i) && info.parentIndices(i) ~= 1
            if strcmpi(info.blockTypeList{i}, 'Outport') || ...
                    (strcmpi(info.blockTypeList{i}, 'Inport') && ~checkIfBlockIsInAction(info, i))
                if isempty(find(directRemoveBlocks == i, 1))
                    srcs = find(info.mainBlocksGraph(:, i) ~= 0);
					srcs = srcs.';
                    dsts = find(info.mainBlocksGraph(i, :) ~= 0);
                    for j = srcs
                        for k = dsts
                            info.mainBlocksGraph(j, k) = info.mainBlocksGraph(j, i);
                            directRemoveBlocks = [directRemoveBlocks, i];
                        end
                    end
                end
            end
        end
    end
    
    %Now remove blocks in the directRemoveBlocks list
    directRemoveBlocks = unique(directRemoveBlocks);
    sortedList = sort(directRemoveBlocks, 'descend');
    for i = sortedList
        info.mainBlockIndices(i) = [];
        info.mainBlocksGraph(i, :) = [];
        info.mainBlocksGraph(:, i) = [];
    end
catch
    error('ERROR: reduceToMainBlocks failed!');
end
end

