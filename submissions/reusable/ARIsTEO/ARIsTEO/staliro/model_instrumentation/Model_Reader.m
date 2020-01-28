% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [non_linear_blocklist, info] = Model_Reader(modelName,exclusion_list,info)
% Annotate the simulink model and save the list of blocklists, saturate and
% switch blocks in the system.
% Use this function independently to obtain the list of swich/saturate
% blocks in the model and develop the exclusion list to run the model
% instrumentation functionality.
% Inputs:
%	modelName -  simulink model name to be instrumented
%	exclusion_list - cell array of list of blocks that are to be excluded 
%   for instrumentation. The cell array must contain the complete path of 
%   the block in the model. 
%   For Ex: exclusion_list{1}=Toy_demo/subsystem1/switch1 will exclude the
%   block switch1 from instrumentation.
% Outputs:
%   non_linear_blocklist -  structure with follpwing fields:
%       switch_blocks - cell array of switch blocks in the system excluding
%       the blocks mentioned in exclusion_list.
%       saturate_blocks - cell array of satutate blocks in the system 
%       excluding the blocks mentioned in exclusion_list. 
%       blockList - list of all the blocks in the model.
%       connHandleList - list handles of the blocks in the model

 % check correctness of inputs
    if (nargin == 0)
          fprintf('\n USAGE: BlackBoxToyotaEngine_added_features(''modelName'')\n');
          fprintf('Please give model name without file extension.\n');
        return;
    elseif (nargin >0) 
        if (isempty(modelName))
        error('\n ERROR: Please pass Simulink model name as a parameter without file extension.\n');
        %return;
        end
        if (nargin > 1)
            if iscell(exclusion_list)
            exclusion_list_array=exclusion_list;
            else
            error('\n the exclusion list must be a cell array of switch/saturate blocks \n')
            end
        elseif(nargin == 1)
        exclusion_list_array={};  
        end
    end
    
    %Initialise the Output
    non_linear_blocklist= struct('switch_blocks',{},'saturate_blocks',{},'blockList',{},'connHandleList',{},'num_org_outports',[],'skipped_list',{});
    
    %info = s2mc(modelName);
    
    blockList = info.blockList;
    handleList = info.handles;
    blockType = info.blockTypeList;
    mainBlockIndices = info.mainBlockIndices;
    numOfMainBlocks = info.numOfMainBlocks;
    mainPorts = info.mainPorts;
    mainDataDepGraph = info.mainDataDepGraph;
    mainBlockhandles = zeros(numOfMainBlocks,1);
    %initialisations
    swcount=0; % Initialise the switch count
    switcharray = {};
    saturation_count=0; % Initialise the saturation count
    saturation_array = {};
    
    %name = get_param(blockList{1}, 'Name');
    fprintf('Model ''%s'' is read. Total %d blocks \n', modelName, length(blockList));
    
%     handleList = cell(length(blockList), 1); % Keeps handles of items
%     inPortList = cell(length(blockList), 1); % If an item is input port, keeps # of port
%     outPortList = cell(length(blockList), 1); % If an item is output port, keeps # of port
%    connHandleList = cell(length(blockList), 1); % If an item is input/output port of its parent, keeps handle of its parent

    if info.wasModelOpenedAlready == 0
        load_system(modelName);
    end
    skip_count = 0;  
    skipped_list = {};
    for i = 1:numOfMainBlocks %length(blockList)
        % switch/saturate blocks in masked subsystem not considered for now.
        % Switch/saturate blocks in masked system identified and ignored
        mainBlockhandles(i) = get_param(blockList{mainBlockIndices{i}},'Handle');
        Parentblock=get_param(blockList{mainBlockIndices{i}},'Parent');
        try
            Parentmaskstatus=get_param(Parentblock,'Mask');
            %Parentmaskstatus='OFF';
        catch
            Parentmaskstatus='OFF';
        end
        if (strcmpi(blockType{mainBlockIndices{i}},'Switch')) && strcmpi(Parentmaskstatus,'OFF')    
             %fprintf('switch block no is %d \n',i);
             exclusion_status=0;            
%              eval([modelName,'([],[],[],''compile'');']);
%              portTypeList = get_param(blockList{mainBlockIndices{i}}, 'CompiledPortDataTypes');
%              portConn = get_param(blockList{mainBlockIndices{i}}, 'PortConnectivity');
%              eval([modelName,'([],[],[],''term'');']);
%              
%              if (strcmp(portTypeList.Inport{1,2},'boolean'))
%                   srchsndle = portConn(2,1).SrcBlock;
%                   swsrctype = get_param(srchsndle,'BlockType');
%                   if strcmpi(swsrctype,'UnitDelay')||strcmpi(swsrctype,'DataStoreRead')
%                       continue;
%                   end
%              end
             for i_mainports = 1:length(mainPorts)
                 if mainPorts(i_mainports).block == mainBlockIndices{i} && ...
                     mainPorts(i_mainports).type == 1 && ...
                     mainPorts(i_mainports).portNo == 2
                     column_pos = i_mainports;
                    break;
                 end
             end
             
             for i_mainports = 1:length(mainPorts)
                 if mainDataDepGraph(i_mainports,column_pos) >0
                     blocknumber = mainPorts(i_mainports).block;
                     swsrcblocktype = blockType{blocknumber};
                     break;
                 end
             end
             if strcmpi(swsrcblocktype,'UnitDelay')||strcmpi(swsrcblocktype,'DataStoreRead')||...
                     strcmpi(swsrcblocktype,'Constant')
                    skip_count = skip_count+1;
                    skipped_list{skip_count} = blockList{mainBlockIndices{i}}; 
                    continue;
             end
             
             if (~isempty(exclusion_list_array))
                 for i_excl_list = 1: length(exclusion_list_array)
                     if strcmp(blockList{mainBlockIndices{i}},exclusion_list_array{i_excl_list})
                         exclusion_status=1;
                         break;
                     end
                 end
                 if exclusion_status==1
                     continue;
                 end
             end
             switchname = blockList{mainBlockIndices{i}};
             swcount=swcount+1;
             switcharray{swcount,1}=switchname;
             switcharray{swcount,2} = mainBlockIndices{i};
        elseif (strcmpi(blockType{mainBlockIndices{i}},'Saturate')) %&& strcmpi(Parentmaskstatus,'OFF'))    
             %fprintf('saturation block no is %d \n',i);
             exclusion_status=0;
             if (~isempty(exclusion_list_array))
                 for i_excl_list = 1: length(exclusion_list_array)
                     if strcmp(blockList{mainBlockIndices{i}},exclusion_list_array{i_excl_list})
                         exclusion_status=1;
                         break;
                     end
                 end
                 if exclusion_status==1
                     %exclusion_status=0;
                     continue;
                 end
             end
             saturation_count=saturation_count+1;
             saturation_name = blockList{mainBlockIndices{i}};
             saturation_array{saturation_count,1} = saturation_name;
             saturation_array{saturation_count,2} = mainBlockIndices{i};
        end
    end
    
    outport_array = find_system(modelName,'SearchDepth',1,'BlockType','Outport');
    non_linear_blocklist(1).num_org_outports = length(outport_array);
    % update the output structure    
    non_linear_blocklist(1).switch_blocks= switcharray;
    non_linear_blocklist(1).saturate_blocks= saturation_array;
    non_linear_blocklist(1).blockList= blockList;
    %non_linear_blocklist(1).connHandleList = connHandleList;
    non_linear_blocklist(1).connHandleList = mainBlockhandles;
    non_linear_blocklist(1).skipped_list = skipped_list;
    fprintf(' Model read done \n');
end
