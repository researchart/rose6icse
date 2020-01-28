% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  [connectivity_matrix] = connectivity_map_generator(modelName,non_linear_blklist)

    % Turn off warnings that can arise from model to be opened/loaded
    warning('off');

    % lookUpTable keeps size of data types that are read by user input
    % lookUpTableIndex is next index for lookUpTable. 
    % (number of entries + 1)
    global lookUpTable;
    global lookUpTableIndex;
    global parentsList;
    global blockTypeList;
    global discardList;
    global connMatrix;
    global portConnMatrix;
    lookUpTableIndex = 1;
    global simpleBlockList;
    errorOccured = 0;
    
    global blockList; % will come from modelReader
    global handleList;
    
    blockList=non_linear_blklist;
    % List of handle of each block 
    handleList = cell(length(blockList), 1); % Keeps handles of blocks
    inPortList = cell(length(blockList), 1); % If an item is input port, keeps # of port
    outPortList = cell(length(blockList), 1); % If an item is output port, keeps # of port
    connHandleList = cell(length(blockList), 1); % If an item is input/output port of its parent, keeps handle of its parent
   
    for i = 1:length(blockList)

        fprintf('\n\nblock %d) ',i);
        name = get_param(blockList{i}, 'Name');   

        fprintf(' Name= %s ',name); 
        handleList{i} = get_param(blockList{i}, 'Handle');
        try
            blockType = get_param(blockList{i}, 'BlockType');
%           blockType = cellstr(get_param(blockList{i}, 'BlockType'));

            %fprintf(' BlockType= %s ',blockType);
            if(strcmpi(blockType,'RelationalOperator')||strcmpi(blockType,'Logic'))
                oper = get_param(blockList{i}, 'Operator');
%                disp(oper);
                %fprintf(' Operator= %s ',oper);
            elseif(strcmpi(blockType,'Constant'))
                sname{cnt,1} = get_param(blockList{i}, 'Value');
                cnt=cnt+1;
%                disp(cvalue);
                %fprintf('Value %s',cvalue);
            end

        catch
            blockType = 'none';
        end
        if (strcmpi(blockType,'Inport'))
            inPortList{i} = get_param(blockList{i}, 'Port');
            outPortList{i} = 0;
            connHandleList{i} = get_param(get_param(blockList{i}, 'Parent'), 'Handle');
        elseif (strcmpi(blockType,'Outport'))
            inPortList{i} = 0;
            outPortList{i} = get_param(blockList{i}, 'Port');
            connHandleList{i} = get_param(get_param(blockList{i}, 'Parent'), 'Handle');
        else
            connHandleList{i} = handleList{i};
            inPortList{i} = 0;
            outPortList{i} = 0;
        end
    end
    % List of handle of parent of each block  
    parentsList = cell(length(blockList), 1); % Keeps handles of parents of blocks
    for i = 1:length(blockList)
        try
            parentsList{i} = get_param(get_param(blockList{i}, 'Parent'), 'Handle');
        catch
            parentsList{i} = 0;
        end
    end
    
    % List of strings of block types of each block   
    blockTypeList = cell(length(blockList), 1); % Keeps types of blocks as strings
    for i = 1:length(blockList)
        try
            blockTypeList{i} = cellstr(get_param(blockList{i}, 'BlockType'));
        catch
            blockTypeList{i} = 'none';
        end
    end
    % List of blocks that are marked as discard:1 or not discard:0
    discardList = cell(length(blockList), 1); % Flags items to be discarded
    % Connectivity matrix is n by n matrix.
    % Value of connMatrix(i,j) : 
    % amount of data (in bytes) sent from i to j.  
    connMatrix = zeros(length(blockList));       
    portConnMatrix = cell(length(blockList));
    % Compile the model to be able to read port dimensions etc.
    % This information is available after model is compiled.
    eval([modelName,'([],[],[],''compile'');']);   
    for i = 2:length(blockList)
%         try
            findDestinations(i);
%         catch
%             fprintf('Could not find destinations for %d\n', i);
%             errorOccured = 1;
%         end
    end
    for i = 2:length(blockList)
        for j = 2:length(blockList)
            if ~isempty(portConnMatrix{i,j})
                s=size(portConnMatrix{i,j});
                for k=1:s(2)
                    fprintf('\nfrom %d(%d) to %d(%d) ',i,portConnMatrix{i,j}(k).src,j,portConnMatrix{i,j}(k).dst)
                end
            end
        end
    end  
    try
        newConnMatrix = discardItemsFromConnMatrix(connMatrix, discardList);       
    catch
        fprintf('Error occured. i=%d\n', i);
        errorOccured = 1;
    end

    eval([modelName,'([],[],[],''term'');']);
    
%      if (errorOccured == 0)
%         prompt = sprintf('Do you want to see task graph?(Y/N) ');
%         wantToSeeGraph = input(prompt, 's');
%         if ((wantToSeeGraph == 'Y') || (wantToSeeGraph == 'y'))
%             % Create graph with connectivity matrix and node names as block names
%             G = biograph(newConnMatrix, simpleBlockList, 'ShowWeights', 'on');
%             h = view(G);
%         end
%      end
    connectivity_matrix= connMatrix; 
end

function simpleConnMatrix = discardItemsFromConnMatrix(connMatrix, discardList)
    global blockList;
    global simpleBlockList;
    numberOfDeleted = 0;
    simpleBlockList = blockList;
    
    simpleConnMatrix = connMatrix;
    for i = 1:length(discardList)
        if (i == 1) || (discardList{i} == 1)
            simpleConnMatrix(i-numberOfDeleted, :) = [];
            simpleConnMatrix(:, i-numberOfDeleted) = [];
            simpleBlockList(i-numberOfDeleted) = [];
            numberOfDeleted = numberOfDeleted + 1;
        end
    end
end

% Returns index of block with given handle, -1 if handle is not found
function relatedIndex = getIndexFromHandle(blockHandle)
    global handleList;
    
    relatedIndex = -1;
    for i = 1:length(handleList)
        if handleList{i} == blockHandle
            relatedIndex = i;
            break
        end
    end
end

% Returns index of first child if the block is parent of another block, 0 otherwise
function isParent = checkIfBlockIsAParent(blockHandle)
    global parentsList;

    isParent = 0;
    for i = 1:length(parentsList)
        if parentsList{i} == blockHandle
            isParent = i;
            break
        end
    end
end

function findDestinations(blockIndex)
    global blockList;
    global handleList;
    global discardList;
    global blockTypeList;
    global lookUpTable;
    global lookUpTableIndex;
    
    blockType = blockTypeList{blockIndex};

    % If block is Inport and parent is not model itself or 
    % if block is parent of other block(s) or 
    % if block is Outport, Goto, From, DataStoreMemory, discard the block.
    if strcmpi(blockType,'Inport') || strcmpi(blockType,'Outport')
        parentsHandle = get_param(get_param(blockList{blockIndex}, 'Parent'), 'Handle');
        if parentsHandle == handleList{1} % Parent is model => this block is Inport/Outport of model, Do not discard.
            discardList{blockIndex} = 0;
        else
            discardList{blockIndex} = 1;
        end
    elseif strcmpi(blockType,'Goto') || strcmpi(blockType,'From') ...
           || strcmpi(blockType,'DataStoreMemory') || strcmpi(blockType,'none') ...
           || strcmpi(blockType,'TriggerPort')
        discardList{blockIndex} = 1;
    elseif checkIfBlockIsAParent(handleList{blockIndex}) > 0
        discardList{blockIndex} = 1;
    else
        discardList{blockIndex} = 0;
    end
    
    % Process block if it is not discarded
    if discardList{blockIndex} == 0
%         try
            % Get all ports (in/out) of block.
            portsOfBlock = get_param(blockList{blockIndex}, 'PortConnectivity');

            % portWidthList: Keeps width of each port.
            % portTypeList: Keeps data type of each port.
            try
                portWidthList = get_param(blockList(blockIndex), 'CompiledPortWidths');
                portTypeList = get_param(blockList(blockIndex), 'CompiledPortDataTypes');
                portDimOK = 1;
            catch
                portWidthList = {};
                portTypeList = {};
                portDimOK = 0;
            end

            outPortIndex = 0; % blockPortIndex starts from input ports but outPortIndex is 1 for first output port.
            for blockPortIndex = 1:length(portsOfBlock) % for each port
                if ~isempty(portsOfBlock(blockPortIndex,1).DstBlock)
                    outPortIndex = outPortIndex + 1;
                    if isempty(portsOfBlock(blockPortIndex,1).SrcBlock)
                        fprintf('\n %d) SrcBlock is empty ',blockIndex)
                    end
                end
                for blockDestination = 1:length(portsOfBlock(blockPortIndex,1).DstBlock) % for each destination
                    fprintf(' DstPort(%d)=%d ',blockDestination,portsOfBlock(blockPortIndex,1).DstPort(blockDestination));
                    % --- Find Size Of Port ---
                    % Read width of port
                    if (portDimOK == 1)
                        edgeCost = portWidthList{1,1}.Outport(outPortIndex);
                    else
                        edgeCost = 1;
                    end
                    % Determine size of data type
                    try
                        dataSize = sizeof(portTypeList{1,1}.Outport{outPortIndex});
                    catch
                        dataSize = -1;

                        for ti = 1:lookUpTableIndex - 1
                            if (strcmp(lookUpTable{ti, 1}, portTypeList{1,1}.Outport{outPortIndex}))
                                dataSize = lookUpTable{ti, 2};
                            end
                        end

                        while (dataSize < 0)
%                            prompt = sprintf('What is the size of %s in bytes? ', portTypeList{1,1}.Outport{outPortIndex});
                                dataSize=1;
                            try
                                dataSize = 1;
                            catch
                                dataSize = -1;
                            end
                        end
                        lookUpTable{lookUpTableIndex, 1} = portTypeList{1,1}.Outport{outPortIndex};
                        lookUpTable{lookUpTableIndex, 2} = dataSize;
                        lookUpTableIndex = lookUpTableIndex+1;
                    end
                    edgeCost = edgeCost * dataSize;
                    % --- End of Find Size of Port ---
                    dstBlockIndex = getIndexFromHandle(portsOfBlock(blockPortIndex,1).DstBlock(blockDestination)); % get index of destination
                    listDestinations(blockIndex, edgeCost, dstBlockIndex, portsOfBlock(blockPortIndex,1).DstPort(blockDestination),(blockPortIndex-1));
                end
            end
%         catch
%             fprintf('Could not get port information of %d\n', blockIndex);
%         end
    end
end

function listDestinations(sourceBlockIndex, edgeCost, blockIndex, dstPort,srcPort)
    global blockList;    
    global blockTypeList;
    global parentsList;
    global handleList;
    global connMatrix;
    global portConnMatrix;
    
    blockHandle = handleList{blockIndex};
    blockType = blockTypeList{blockIndex};
    inputPortNo = dstPort + 1; % Destination ports start from 0 but Port attribute of an Inport or Outport start from 1
    firstChild = checkIfBlockIsAParent(blockHandle);
   
    ports.dst=dstPort;
    ports.src=srcPort;
    
    if strcmpi(blockType,'Inport') || strcmpi(blockType,'From') % This destination is an Inport or From:
        fprintf('Error: block index %d is %s and can not be destination of a block\n', blockIndex, blockType);
    elseif firstChild > 0 % This destination is parent of some block(s)
        foundInputChild = 0;
        hasTriggerChild = 0;
        for i = firstChild:length(parentsList) % search children
             if parentsList{i} == blockHandle % this (i) is a child
                 if strcmpi(blockTypeList{i},'Inport') % This child is an Inport
                     % Check if this child is the inport that we are
                     % looking for
                     if (inputPortNo == str2num(get_param(blockList{i}, 'Port'))) || inputPortNo == 0 %inputPortNo = 0 means connect everything
                         portsOfChild = get_param(blockList{i}, 'PortConnectivity');
                         for childPortIndex = 1:length(portsOfChild)
                            for childDestination = 1:length(portsOfChild(childPortIndex,1).DstBlock) % for each destination
                                dstBlockIndex = getIndexFromHandle(portsOfChild(childPortIndex,1).DstBlock(childDestination)); % get index of destination
                                listDestinations(sourceBlockIndex, edgeCost, dstBlockIndex, portsOfChild(childPortIndex,1).DstPort(childDestination),srcPort); % mark each destination of inport child
                            end
                         end
                         foundInputChild = 1;
                         break; % We already found and processed related inport child, no need to search other children.
                     end
                 elseif strcmpi(blockTypeList{i},'TriggerPort') % This child is a TriggerPort
                     hasTriggerChild = 1; % Mark that this block has a trigger input. We will use this if we can't find a matchinf Inport.
                 end
             end
        end
        if foundInputChild == 0 % Could not find related Inport child
            if (hasTriggerChild == 1) || (inputPortNo == 0) % That means this connection goes to or comes from trigger. We will connect to all children
                for i = firstChild:length(parentsList) % search children
                    if parentsList{i} == blockHandle % this (i) is a child
                         if ~(strcmpi(blockTypeList{i},'Inport') || strcmpi(blockTypeList{i},'Outport') ...
                                 || strcmpi(blockTypeList{i},'TriggerPort') || strcmpi(blockType,'Goto') ...
                                 || strcmpi(blockType,'From') || strcmpi(blockType,'DataStoreMemory') || strcmpi(blockType,'none'))
                              listDestinations(sourceBlockIndex, edgeCost, i,-1,-1); % mark each child as a destination
%                            listDestinations(sourceBlockIndex, edgeCost, i, portsOfParent(portIndex,1).DstPort(parentDestination),srcPort); % mark each child as a destination
                         end
                    end
                end
            end
        end
    elseif strcmpi(blockType,'Outport') % This destination is an Outport
        outPortNo = str2num(get_param(blockList{blockIndex}, 'Port'));
        
        if parentsList{blockIndex} == handleList{1} % Parent is model itself so this block is outport of the model
           connMatrix(sourceBlockIndex, blockIndex) = edgeCost;
           portConnMatrix{sourceBlockIndex, blockIndex} = [portConnMatrix{sourceBlockIndex, blockIndex} ports];
        else % Find destinations of parent
            parentIndex = getIndexFromHandle(parentsList{blockIndex});
            portsOfParent = get_param(blockList{parentIndex}, 'PortConnectivity');
            parentsOutPortIndex = 0;
            for portIndex = 1:length(portsOfParent) % for each port
                if ~isempty(portsOfParent(portIndex,1).DstBlock) % This port is an output port
                    parentsOutPortIndex = parentsOutPortIndex + 1;
                end
                if parentsOutPortIndex == outPortNo % This is the port of parent that we are looking for
                    for parentDestination = 1:length(portsOfParent(portIndex,1).DstBlock) % for each destination
                        dstBlockIndex = getIndexFromHandle(portsOfParent(portIndex,1).DstBlock(parentDestination)); % get index of destination
                        listDestinations(sourceBlockIndex, edgeCost, dstBlockIndex, portsOfParent(portIndex,1).DstPort(parentDestination),srcPort); % mark each destination of inport child
                    end
                end
            end
        end
        %applied bug dix provide by Erkan. Taking into consideration tag
        %visibilty as well when updating info of from blocks
    elseif strcmpi(blockType,'Goto') % This destination is a Goto
        % Find all 'From's and recursively call this function for each
        % destination of each 'From'
        % bug fix provided by Erkan to resolve Goto-From visibility problem
            gotoTag = cellstr(get_param(blockList{blockIndex}, 'GotoTag'));
            gotoVisibility = get_param(blockList{blockIndex}, 'TagVisibility');
            %gotoParent = info.parentHandles(blockIndex); %checking parent of goto
            gotoParent = parentsList(blockIndex); %checking parent of goto - by erkan
            for fromIndex = 2:length(blockList) % searching corresponding From
                if strcmpi(cellstr(get_param(blockList{fromIndex}, 'BlockType')), 'From') % fromIndex is a From
                    fromTag = cellstr(get_param(blockList{fromIndex}, 'GotoTag'));
                    if strcmpi(gotoTag, fromTag) % This is a corresponsing "From"
                        %fromParent = info.parentHandles(fromIndex);%checking parent of from
                        fromParent = parentsList(fromIndex);%checking parent of from - by erkan
                        if ((strcmp(gotoVisibility, 'global') == 1) || cell2mat(gotoParent) == cell2mat(fromParent)) % if goto tag visibility is local, then only from tags in same subsystem receives data.
                            portsOfFrom = get_param(blockList{fromIndex}, 'PortConnectivity');
                            for portIndex = 1:length(portsOfFrom) % for each port
                                for fromDestination = 1:length(portsOfFrom(portIndex,1).DstBlock) % for each destination of from

                                    dstBlockIndex = getIndexFromHandle(portsOfFrom(portIndex,1).DstBlock(fromDestination)); % get index of destination
                                    dstPort = portsOfFrom(portIndex,1).DstPort(fromDestination);
                                    listDestinations(sourceBlockIndex, edgeCost, dstBlockIndex, dstPort, srcPort); % mark each destination of inport child

                                end
                            end
                        end
                    end
                end
            end
    else
        connMatrix(sourceBlockIndex, blockIndex) = edgeCost;
        portConnMatrix{sourceBlockIndex, blockIndex} = [portConnMatrix{sourceBlockIndex, blockIndex} ports];
    end
end

function nbytes = sizeof(precision)
%sIZEOF  return the number of bytes of a builtin data type.
%   NBYTES = SIZEOF(PRECISION) returns the number of bytes of a single
%   element of class PRECISION.  PRECISION must be the name of one of the
%   builtin data types.
%
%   Knowing the number of bytes for a datatype is useful when performing
%   file I/O where some operations are defined in numbers of bytes.
%
%   Example:
%       nbytes = sizeof('single');

% Charles Simpson <csimpson at-symbol gmail dot-symbol com>
% 2007-09-26

    error(nargchk(1, 1, nargin, 'struct'));

    try
        z = zeros(1, precision); % # ok, we use 'z' by name later.
    catch
        error('Unsupported class for finding size');
    end

    w = whos('z');
    nbytes = w.bytes;
end

% function boolblockindex(modelName,connHandleList)
% 
%  global blockList;
%  %global connMatrix;
%  global boolindexmat;
%  
%  swcount=0;
%  for i = 2:length(blockList)
%          blockType = get_param(blockList{i}, 'BlockType');
%          %fprintf(' BlockType= %s ',blockType);
%          
%          if(strcmpi(blockType,'Switch'))
%             fprintf(' BlockType= %s \n',blockType); 
%             fprintf('switch block no is %d \n',i);
%             %checkparent=get_param(blockList{1},'Handle')
%             swcount=swcount+1;
%             switchname= get_param(blockList{i}, 'Name')
%             switcharray{swcount,1}=cellstr(switchname); % name of sw block
%             switcharray{swcount,2}=i; % sw block number
%          end
%  end          
%                 
%  eval([modelName,'([],[],[],''compile'');']);    
%      
%     % Check data type connected to switch block trigger input
%     % and save the info
%         for i=1:swcount
%                 portWidthList = get_param(blockList(switcharray{i,2}), 'CompiledPortWidths');
%                 portTypeList = get_param(blockList(switcharray{i,2}), 'CompiledPortDataTypes');
%                 portConn = get_param(blockList(switcharray{i,2}), 'PortConnectivity');
%                 portDimOK = 1;
% 
%                 if(strcmp(portTypeList{1,1}.Inport{1,2},'double'))
%                     call=1
%                     switcharray{i,3}=1; % storing a 1 to imply that a double data type is connected to switch
%                     Switchconnhandle(i,1)= portConn{1,1}(2,1).SrcBlock; %storing the handle of source block having double data type
%                 elseif(strcmp(portTypeList{1,1}.Inport{1,2},'boolean'))
%                     switcharray{i,3}=2; % there is a boolean connection
%                     Switchboolconnhandle(i,1)= portConn{1,1}(2,1).SrcBlock;
%                 else
%                     switcharray{i,3}=0;
%                 end
%     
%         end
%      
%   eval([modelName,'([],[],[],''term'');']); 
%   
%   global boolcellmap;
%   boolcellmap=cell(swcount,1);
%   for i=1:swcount
%         if (switcharray{i,3}==2)
%             for j=1:length(blockList)
%                 if(connHandleList{j}==Switchboolconnhandle(i,1))
%                     boolsourceblock=j
%                     blockList{j}  
%                     %boolindexvalue=0;
%                     %global boolindexmat;
%                     boolindexmat=[];
%                     extractbool(boolsourceblock)
%                     boolindexmat((length(boolindexmat)+1),1)= boolsourceblock;
%                     boolcellmap{i,1}= boolindexmat;
%                     break;
%                 end   
%             end
%           
%         end
%         %boolcellmap{i,1}= boolindexmat;
%   end
%   
% end
% 
% function extractbool(boolsourceblock)
%   global connMatrix
%   global blockList
%   global boolindexmat
%   
%  
%    foundconnection=0;
%   
%     for ipos=1 : length(blockList)
%         if (connMatrix(ipos,boolsourceblock)~=0)
%             %boolindexvalue= boolindexvalue+1;
%             foundconnection=1;
%             
%             boolindexvalue= length( boolindexmat);
%             repeatflag=0;
%             
%         if (boolindexvalue~=0)
%             for j=1:boolindexvalue
%                 if (boolindexmat(j,1)==ipos)
%                     repeatflag=1;
%                     break;
%                 end
%             end
%             
%             if (repeatflag==0)
%                 boolindexmat(boolindexvalue+1,1)=ipos;
%             end
%             
%         else
%             boolindexmat(1,1)=ipos;
%         end
%         
%         extractbool(ipos);
%             
%         end
%         
%     end 
%     
%     if(foundconnection==0)  
%         %boolindexmat(boolindexvalue,1)=0;
%         return;
%     end
%     
% end
% 
% 
% function [boolconnarray]=extractboolconnmap()
% 
% %boolconnmat=zeros(boolsize);
% global connMatrix;
% %global boolindexmat;
% global boolcellmap;
% boolconnarray= cell (length(boolcellmap),1);
%     for i= 1:length (boolcellmap)
%         temp= boolcellmap{i,1};
%         boolconnmat=[];
%         for j=1:length (temp)
%             for k=1:length (temp)
%                 if (connMatrix(temp(j),temp(k))~=0)
%                     boolconnmat(j,k)=1;
%             
%                 else
%                     boolconnmat(j,k)=0;
%                 end
%             end
%         end
%         boolconnarray{i,1}= boolconnmat;
%     end
% end
% 
% 
% function boolstr=producestring(boolsourceblock, initialpos,swblockindex)    
% 
%  global boolstring;
%  global boolconncell;
%  global blockList;
%  global boolcellmap ;
%  
%  boolstr='';
%  temp= boolconncell{swblockindex,1};
%  boolmatlist= boolcellmap{swblockindex,1};
%  
%  sourcetype=get_param(blockList(boolsourceblock), 'blockType');
%         if (strcmp(sourcetype , 'Logic')|| strcmpi(sourcetype, 'RelationalOperator'));
%             sourceop= get_param(blockList(boolsourceblock), 'Operator');
%         elseif(strcmp(sourcetype , 'Constant'))
%             sourceop= get_param(blockList(boolsourceblock), 'Value');
%         end
%         if (strcmp(sourcetype , 'Inport'))
%             sourceop= get_param(blockList(boolsourceblock), 'Name');
%         end
%  foundconnection=0;  
%  
%  tempstring{1,1}='';
%  count=0;
%  for i= 1:length(temp)
%     
%     if (temp(i,initialpos)~=0)
%         foundconnection=1;
%         
%         newboolsourceblock=boolmatlist(i,1);
%         newinitialpos=i;
%         
%         tempstring{count+1,1}=producestring(newboolsourceblock,newinitialpos,swblockindex);
%         
%         if(isempty(tempstring{count+1,1}))
%             type=get_param(blockList(newboolsourceblock), 'blockType');
%             if (strcmp(type , 'Logic')|| strcmpi(type, 'RelationalOperator'));
%                 op= get_param(blockList(newboolsourceblock), 'Operator');
%             elseif(strcmp(type , 'Constant'))
%                 op= get_param(blockList(newboolsourceblock), 'Value');
%             end
%             if (strcmp(type , 'Inport'))
%                 op= get_param(blockList(newboolsourceblock), 'Name');
%             end
%             tempstring(count+1,1)=strcat('(',op,')');
%             count=count+1;
%         
%         else
%             %tempstring(count+1,1)=strcat('(',tempstring{count+1,1},')');
%             count=count+1;
%         end
%         
%     end
%     if(foundconnection==1)
%         boolstring= strcat('(',boolstring,')');
%     end
%  end
%  if(foundconnection==0)
%      boolstr='';
%      return;
%  else
%      for j=1:count-1 
%         boolstr=strcat(boolstr,tempstring{j,1},sourceop);
%      end
%      boolstr=strcat('(',boolstr,tempstring{count,1},')');
%  end
% 
% end
%        
% function operand= getoperand(type)
%     operand= get_param(blockList(newboolsourceblock), 'Operator');
%     switch operand
%         case 'OR'
%             operand = '+';
%         case 'AND'
%             opernad ='*';
%         case 'EXOR'
%             operand = '^';
%         case 'NOT'
%             operand = '''';
%     end
% end
    
        
    
