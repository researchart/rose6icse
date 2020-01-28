% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [switch_block_info] = Switch_Instrument(modelName,switcharray,blockList,connHandleList,info,num_org_outports)
% Instruments the switch blocks in the model with output ports and
% returns an output struct with switch block information.
% Inputs:
%	modelName -  simulink model name to be instrumented
%	switcharray - cell array of list of switch blocks that are to be  
%   instrumented. The cell array must contain the complete path of 
%   the block in the model. 
%   For Ex: saturate_blocks{1}=Toy_demo/subsystem1/switch1 will instrument 
%   the block switch1.
%   block_List - list of the blocks in the model obtained from Model_Reader
%   connHandleList - list handles of the blocks in the model
%
% Outputs:
%   switch_block_info -  structure with follpwing fields:
%      bool_blocks - structure array for boolean switch blocks with fields
%           * conn_handle - array of handles of source block connected to
%           the switch blocks.
%           * rel_conn_handle - struture storing information of the source
%           blocks connected to relational operator blocks. 
%      double_blocks - structure array for double switch blocks with fields
%           * threshold - array containing switchng thresholds
%           corresponding to each  double type switch blocks
%           * criteria - array containng criteria for switching. stores
%           either '>=' or '>' corresponding to each doubele switch blocks.
%           *outportindex - array of output port index added corresponding
%           to each double type switch block
%      num_of_boolsw - number of boolean type switch blocks
%      num_of_doublesw - number of double type switch blocks
%      numport_index - the index where Numerical outport ends
%      endport_index - end index of output port added in the model
%      instrumentation 

%%
    %Initialisation output structure
    switch_block_info=struct('bool_blocks',{},'double_blocks',{},'num_of_boolsw',0,...
        'num_of_doublesw',0,'numport_index',0,'endport_index',0, ...
    'LT_float',[],'LT_bool',[],'LT_remove',[]);
    
    % Copy input arguments
    if isempty(switcharray)
       swcount = 0;
    else
        switch_cell_size=size(switcharray);
        swcount= switch_cell_size(1,1);% get number of rows
    end
    
    mainBlockIndices = info.mainBlockIndices;
    numOfMainBlocks = info.numOfMainBlocks;
    mainPorts = info.mainPorts;
    mainDataDepGraph = info.mainDataDepGraph;
    %eval([modelName,'([],[],[],''compile'');']);    
    % Check the data type connected to switch block trigger input
    % and save the info in cell arrays
%     Switchconnhandle=zeros(swcount,1);
%     Switchconnhandlebool=zeros(swcount,1);
    Switchconnhandle=[];%zeros(swcount,1);
    Switchconnhandlebool=[];%zeros(swcount,1);
    doubleswitch=0;
    boolswitch=0;
%     for i=1:swcount
%         portTypeList = get_param(switcharray{i,1}, 'CompiledPortDataTypes');
%         portConn = get_param(switcharray{i,1}, 'PortConnectivity');
%         if(strcmp(portTypeList.Inport{1,2},'double'))
%             %call=1;
%             doubleswitch=doubleswitch+1;
%             switcharray{i,3}=1; % storing a 1 to imply that a double data type is connected to switch
%             %Switchconnhandle(i,1)= portConn(2,1).SrcBlock; %storing the handle of source block having double data type
%             %Switchconnhandle(i,2)= portConn(2,1).SrcPort+1;
%             Switchconnhandle(doubleswitch,1)= portConn(2,1).SrcBlock; %storing the handle of source block having double data type
%             Switchconnhandle(doubleswitch,2)= portConn(2,1).SrcPort+1;
%             %doubleswitch=doubleswitch+1;
%         elseif (strcmp(portTypeList.Inport{1,2},'boolean'))
%             boolswitch=boolswitch+1;
%             switcharray{i,3}=2; % there is boolean connection
% %             Switchconnhandlebool(i,1)= portConn(2,1).SrcBlock;%storing the handle of source block having bool data type
% %             Switchconnhandlebool(i,2)= portConn(2,1).SrcPort+1;
%             Switchconnhandlebool(boolswitch,1)= portConn(2,1).SrcBlock;%storing the handle of source block having bool data type
%             Switchconnhandlebool(boolswitch,2)= portConn(2,1).SrcPort+1;
%             %boolswitch=boolswitch+1;
%         end
%     end
    for i=1:swcount
        for i_mainports = 1:length(mainPorts)
                 if mainPorts(i_mainports).block == switcharray{i,2} && ...
                     mainPorts(i_mainports).type == 1 && ...
                     mainPorts(i_mainports).portNo == 2
                    if(strcmp(mainPorts(i_mainports).dataType,'double'))
                        switchtype = 'double';
                    elseif strcmp(mainPorts(i_mainports).dataType,'boolean')
                        switchtype = 'boolean';
                    end
                    column_pos = i_mainports;
                    break;
                 end
        end
      
        for i_mainports = 1:length(mainPorts)
             if mainDataDepGraph(i_mainports,column_pos)>0
                blocknumber = mainPorts(i_mainports).block;
                if(strcmp(switchtype,'double'))
                    doubleswitch=doubleswitch+1;
                    switcharray{i,3}=1;
                    Switchconnhandle(doubleswitch,1) = get_param(blockList{blocknumber},'Handle');%storing the handle of source block having double data typ
                    Switchconnhandle(doubleswitch,2)= mainPorts(i_mainports).portNo;
                    break;
                elseif strcmp(switchtype,'boolean')
                    boolswitch=boolswitch+1;
                    switcharray{i,3}=2;
                    Switchconnhandlebool(boolswitch,1) = get_param(blockList{blocknumber},'Handle');
                    Switchconnhandlebool(boolswitch,2) = mainPorts(i_mainports).portNo;
                    break;
                end
             end
        end             
    end
    %eval([modelName,'([],[],[],''term'');']);
    
    if boolswitch~=0
        connectivity_matrix = info.mainBlocksGraph;
        [bool_blocklist_cell,bool_conn_matrix_cell]=process_bool(blockList,connHandleList,Switchconnhandlebool,connectivity_matrix,info);
        bool_size= size(bool_blocklist_cell);
        Relsourcehandle_cell = cell(bool_size(1,1),1);%cell(switch_bool_size(1,1),1);
    else
        Relsourcehandle_cell = {};
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   %switch_bool_size= size(Switchconnhandlebool);
   
   
   Relsourcehandle=struct('source1',[],'source1type','','srcprt1','','source2type','','source2',[],'srcprt2','','out1',[],'out2',[]);
   
   
   if boolswitch~=0
       eval([modelName,'([],[],[],''compile'');']);
       for  i=1: bool_size(1,1) %switch_bool_size(1,1)
            %portWidthList = get_param(blockList(switcharray{i,2}), 'CompiledPortWidths');
            %portTypeList = get_param(Switchconnhandlebool(i,1), 'CompiledPortDataTypes');
            if (~isempty(bool_blocklist_cell{i}))
                bool_blocklist= bool_blocklist_cell{i};
                rel_count=0;
                for j=1:length(bool_blocklist)
                    blockType = cellstr(get_param(blockList{bool_blocklist(j)}, 'BlockType'));
                    if(strcmp(blockType,'RelationalOperator'))  
                        rel_count=rel_count+1;
                        portConn = get_param(blockList{bool_blocklist(j)}, 'PortConnectivity');
                        Inpblock1= portConn(1,1).SrcBlock; %storing the handle of source block 1
                        srcprt1 = portConn(1,1).SrcPort;
                        Inpblock2= portConn(2,1).SrcBlock;%storing the handle of source block 2
                        srcprt2 = portConn(2,1).SrcPort;
                        % Use structures to store the handle of blocks
                        % connected to relational and that are not constant blocks
                        Relsourcehandle(rel_count).source1type = get_param(Inpblock1, 'BlockType');
                        Relsourcehandle(rel_count).source1 = Inpblock1; %handle of source block1 of relational operator
                        Relsourcehandle(rel_count).srcprt1 = srcprt1;
                        Relsourcehandle(rel_count).source2type= get_param(Inpblock2, 'BlockType');
                        Relsourcehandle(rel_count).source2=Inpblock2;%handle of source block2 of relational operator 
                        Relsourcehandle(rel_count).srcprt2 = srcprt2;
                        %end
                    end
                end
                Relsourcehandle_cell{i}=Relsourcehandle;
            else
                Relsourcehandle_cell{i}=[];
            end   
       end
       eval([modelName,'([],[],[],''term'');']);
   end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
   
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 newoutportnumber=0;
 mainparenthandle=get_param(blockList{1},'Handle');
 newoutport=0;
 pos = [1000 125 1025 135];
 %Section adds outports for double type switch blocks before the Numerical
 %ports for bool type switches
 switchdouble_info=struct('threshold',[],'criteria','','outportindex',[]);
 double_count=0;
 greatestnumoutportval = 0;
 for i_count=1:swcount
    if (switcharray{i_count,3}==1)
        %for j=1:numOfMainBlocks %length(blockList)
            %if(connHandleList(j) == Switchconnhandle(i_count,1))
                double_count= double_count+1;
                newoutport=newoutport+1;
                outportstring=num2str(newoutport);
                outportstring=strcat('out-',outportstring); % to create new name for the outport that is going to be added
                pos=pos+ [0 50 0 50];% update the position coordinates of the block to be addeded to avoid overlap
                open_system(modelName);
                blkname=get_param(Switchconnhandle(double_count,1), 'Name');
                childblockhandle = Switchconnhandle(double_count,1);
                %srcprt_rel = Switchconnhandle(double_count,2);
                srcportnumber= Switchconnhandle(double_count,2);
                [portexists,portnumber] = checkifoutportexists(modelName, childblockhandle, srcportnumber );
                if portexists == 1
                    newoutportnumber = portnumber;
                else 
                    newoutportnumber=AddOutport(mainparenthandle,childblockhandle,blkname,srcportnumber,pos,outportstring); % call the function to add outport
                end
                if newoutportnumber > greatestnumoutportval
                   greatestnumoutportval = newoutportnumber;
                end
                switchdouble_info(double_count,1).outportindex=newoutportnumber;
                %double_count= double_count+1;
                str_threshold = str2double(get_param(switcharray{i_count,1},'Threshold'));
                % evaluate block variable from input file
                if(isnan(str_threshold))
                    try
                    strvalue=get_param(switcharray{i_count,1},'Threshold');
                    switchdouble_info(double_count,1).threshold = evalin('base', strvalue);
                    catch
                        error('could not evaluate threshold of switch block. please load the variable in base workspace\n')
                    end
                else
                    switchdouble_info(double_count,1).threshold = str_threshold;
                end
                criteria_str= get_param(switcharray{i_count,1},'Criteria');
                if strcmp(criteria_str,'u2 >= Threshold')
                    switchdouble_info(double_count,1).criteria='>=';
                elseif strcmp(criteria_str,'u2 > Threshold')
                    switchdouble_info(double_count,1).criteria='>';
                else
                    switchdouble_info(double_count,1).criteria='~=0';
                end
                %break;
            %end               
        %end
    end
 end
 LT_float = zeros(1,double_count);
 for i_count=1:double_count
     LT_float(1,i_count) = switchdouble_info(double_count,1).outportindex;
 end
 %Section adds Numerical outports. Numerical outports are added first and then Location outports are added. 
 %bool_count=0;
%  greatestnumoutportval = 0;
    for i = 1:boolswitch
       %if (switcharray{i,3} == 2)  
   %%%Gong to fail if both inputs to relational is constant%%%
           %bool_count = bool_count+1;
           Relsourcehandle=Relsourcehandle_cell{i};
           for j=1:length(Relsourcehandle)
               if(~strcmpi(Relsourcehandle(j).source1type,'Constant'))
                   newoutport=newoutport+1;
                   outportstring=num2str(newoutport);
                   outportstring=strcat('out-',outportstring); % to create new name for the outport that is going to be added
                   pos=pos+ [0 50 0 50];  % update the position coordinates of the block to be addeded to avoid overlap
                   open_system(modelName);%open_system(name);

                   blkname=get_param(Relsourcehandle(j).source1, 'Name');
%                    childblockhandle=find_system(Switchconnhandlebool(i,1),'FollowLinks', 'on', ...
%                                     'LookUnderMasks', 'none' );
                   childblockhandle = get_param(Relsourcehandle(j).source1, 'Handle');
                   srcprt_rel = Relsourcehandle(j).srcprt1;
                   srcportnumber= Switchconnhandlebool(i,2);
                   [portexists,portnumber] = checkifoutportexists(modelName, childblockhandle, srcprt_rel + 1);
                   if portexists == 1
                       newoutportnumber = portnumber;
                   else
                   newoutportnumber=AddOutport(mainparenthandle,childblockhandle,blkname,srcportnumber,pos,outportstring); % call the function to add outport
                   end
                   if newoutportnumber > greatestnumoutportval
                       greatestnumoutportval = newoutportnumber;
                   end
                   Relsourcehandle(j).out1=newoutportnumber;
                   
               end

               if(~strcmpi(Relsourcehandle(j).source2type,'Constant'))
                   newoutport = newoutport+1;
                   outportstring = num2str(newoutport);
                   outportstring = strcat('out-',outportstring); % to create new name for the outport that is going to be added
                   pos = pos+ [0 50 0 50]; 
                   open_system(modelName);%open_system(name);

                   blkname = get_param(Relsourcehandle(j).source2, 'Name');
%                    childblockhandle = find_system(Switchconnhandlebool(i,1),'FollowLinks', 'on', ...
%                                     'LookUnderMasks', 'none' );  
                   childblockhandle = get_param(Relsourcehandle(j).source2, 'Handle');
                   srcprt_rel = Relsourcehandle(j).srcprt2;
                   srcportnumber = Switchconnhandlebool(i,2);
                   [portexists,portnumber] = checkifoutportexists(modelName, childblockhandle, srcprt_rel + 1 );
                   if portexists == 1
                       newoutportnumber = portnumber;
                   else
                   newoutportnumber = AddOutport(mainparenthandle,childblockhandle,blkname,srcportnumber,pos,outportstring);
                   end
                   if newoutportnumber > greatestnumoutportval
                       greatestnumoutportval = newoutportnumber;
                   end
                   Relsourcehandle(j).out2 = newoutportnumber;
                   
               end
           end
       %end
    end
 if greatestnumoutportval < num_org_outports
     guardsize = num_org_outports;
 else
    guardsize = greatestnumoutportval;
 end
 %Numerical outports end here. Store the index where Numerical outport ends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Section adds Location outports%%%
bool_count=0;
greatestlocoutportval = 0;
LT_bool = zeros(1,boolswitch);
    for i = 1:swcount
        if (switcharray{i,3}==2)
            bool_count = bool_count +1;
            for j=1:info.numOfMainBlocks%length(blockList)
                if(connHandleList(j) == Switchconnhandlebool(bool_count,1))
                    newoutport = newoutport+1;
                    outportstring = num2str(newoutport);
                    outportstring = strcat('out-',outportstring); % to create new name for the outport that is going to be added
                    pos = pos+ [0 50 0 50];% update the position coordinates of the block to be addeded to avoid overlap
                    open_system(modelName);%open_system(name);         
                    blkname=get_param(blockList{info.mainBlockIndices{j}}, 'Name');          
                    data=get_param(switcharray{i,1},'Handle');
%                     childblockhandle=find_system(data,'FollowLinks', 'on', ...
%                     'LookUnderMasks', 'none' );
                    childblockhandle = Switchconnhandlebool(bool_count,1);
                    
                    %srcprt_rel = 
                    srcportnumber= Switchconnhandlebool(bool_count,2);
                    [portexists,portnumber] = checkifoutportexists(modelName, childblockhandle, srcportnumber );
                    if portexists == 1
                        newoutportnumber = portnumber;
                    else
                        newoutportnumber = AddOutport(mainparenthandle,childblockhandle,blkname,srcportnumber,pos,outportstring); % call the function to add outport
                    end
                    LT_bool(1,bool_count) = newoutportnumber;
                   if newoutportnumber > greatestlocoutportval
                       greatestlocoutportval = newoutportnumber;
                   end
                   
                   break;
                end
            end                
         end       
    end
    
    if greatestlocoutportval < num_org_outports
        endofoutports = newoutportnumber;
    else
        endofoutports = greatestlocoutportval;
    end
    %LT_switch = [LT_float LT_bool];
    LT_remove = [];
    if boolswitch~=0
        for i=1:length(LT_bool)
            if LT_bool(1,i) > num_org_outports
                LT_remove = [LT_remove LT_bool(1,i)];
            end
        end
    end
    %addition of Location outports end here. Store the index.   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DNF_string_12 ={};
    DNF_string_21 = {};
    predicate_table ={};
    if boolswitch~=0
        bool_string = cell(1,length(bool_blocklist_cell));
        for i=1:length(bool_blocklist_cell)
            bool_blocklist=bool_blocklist_cell{i};
            boolsourceblock=bool_blocklist(1);
            bool_string{i}=producestring(modelName,blockList,bool_blocklist,bool_conn_matrix_cell{1},boolsourceblock,1);
        end

       predicate_table = cell(1,length(bool_string));
       processed_bool_string = cell(1,length(bool_string));
       DNF_string_12 = cell(1,length(bool_string));
       DNF_string_21 = cell(1,length(bool_string));
       for i=1:length(bool_string)
         [ processed_bool_string{i},predicate_table{i}] = process_string( bool_string{i});
         str = processed_bool_string{i}; %cell2mat(processed_bool_string{i});
%          DNF_string_12{i} = DNF_CNF(str);
         tempStr=boolean2dnf(char(str));
         tempStr(tempStr == ' ')=[];
         if( tempStr(1)=='(' && isempty(strfind(tempStr,'&')) && isempty(strfind(tempStr,'|')) )
             tempStr=tempStr(2:end-1);
         end
         DNF_string_12{i} = tempStr;
         disp(DNF_string_12{i});
         str = cell2mat(strcat('(',{' ! '},str,{' )'}));
%          DNF_string_21{i} = DNF_CNF(str);
         tempStr=boolean2dnf(char(str));
         tempStr(tempStr == ' ')=[];
         if( tempStr(1)=='(' && isempty(strfind(tempStr,'&')) && isempty(strfind(tempStr,'|')) )
             tempStr=tempStr(2:end-1);
         end
         DNF_string_21{i} = tempStr;
         disp(DNF_string_21{i});
       end
    end
%%
% update output
   switch_block_info(1).bool_blocks.conn_handle= Switchconnhandlebool;
   switch_block_info(1).bool_blocks.rel_conn_handle= Relsourcehandle;
   switch_block_info(1).bool_blocks.predicate_table = predicate_table;
   switch_block_info(1).bool_blocks.DNF_string_12 = DNF_string_12;
   switch_block_info(1).bool_blocks.DNF_string_21 = DNF_string_21;
   switch_block_info(1).double_blocks= switchdouble_info;
   switch_block_info(1).num_of_boolsw=boolswitch;
   switch_block_info(1).num_of_doublesw=double_count;
   switch_block_info(1).numport_index=guardsize;
   switch_block_info(1).endport_index=endofoutports; 
   switch_block_info(1).LT_bool = LT_bool;
   switch_block_info(1).LT_float = LT_float;
   switch_block_info(1).LT_remove = LT_remove;
end

