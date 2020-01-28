% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ saturate_block_info] = Saturation_Instrument(modelName,saturate_blocks,block_List )
% Instruments the saturate blocks in the model with output ports and
% returns an output struct with satutate block information.
% Inputs:
%	modelName -  simulink model name to be instrumented
%
%	saturate_blocks - cell array of list of saturate blocks that are to be  
%   instrumented. The cell array must contain the complete path of 
%   the block in the model. 
%   For Ex: saturate_blocks{1}=Toy_demo/subsystem1/saturate1 will instrument 
%   the block saturate1.
%
%   block_List - list of the blocks in the model obtained from Model_Reader
% Outputs:
%   saturate_block_info -  structure with follpwing fields:
%       conn_handle - nX2 array containing information of source block
%       connected to saturate blocks
%       low_threshold - array containng lower saturation threshold value
%       high_threshold - array containng higher saturation threshold value
%       outport_list - array containing the output port value corresponding
%       to each saturate block that is instrumented.
%       endport_index - the value of last output port index of the last
%       saturate block
%       num_of_satblocks - total number of saturate blocks instrumented

    %Initialisation output structure
    saturate_block_info=struct('conn_handle',{},'low_threshold',[],'high_threshold',[],'outport_list',[],'endport_index',[],'num_of_satblocks',[]);
    
    %Initialisation
    newoutportnumber=0;
   
    %Copy the input arguments
    saturation_array= saturate_blocks;
    blockList= block_List;

    saturation_cell_size=size(saturation_array);
    saturation_count= saturation_cell_size(1,1);% get number of rows

    saturate_outportlist=zeros(saturation_count,1);
    saturate_lowlimit=zeros(saturation_count,1);
    saturate_highlimit=zeros(saturation_count,1);
    
    eval([modelName,'([],[],[],''compile'');']);    
    Saturationconnhandle=zeros(saturation_count,1);
    for i=1:saturation_count

        %portTypeList = get_param(blockList(saturation_array{i,2}), 'CompiledPortDataTypes');
        portConn = get_param(saturation_array{i,1}, 'PortConnectivity');     
        Saturationconnhandle(i,1)= portConn(1,1).SrcBlock;
        Saturationconnhandle(i,2)= portConn(1,1).SrcPort+1;%store the ouportnumber of the source block connected to saturation block
    end
    eval([modelName,'([],[],[],''term'');']);
    
    newoutport=0;
    pos=[0 50 0 50];
    mainparenthandle=get_param(blockList{1},'Handle');
    
    for i=1:saturation_count                         
        newoutport=newoutport+1;
        outportstring=num2str(newoutport);
        outportstring=strcat('sat_out-',outportstring); % to create new name for the outport that is going to be added
        pos=pos+ [0 50 0 50];% update the position coordinates of the block to be addeded to avoid overlap
        open_system(modelName);
        blkhandle = Saturationconnhandle(i,1);
        blkname=get_param(Saturationconnhandle(i,1), 'Name');
        data=get_param(saturation_array{i,1},'Handle');
        childblockhandle=find_system(data,'FollowLinks', 'on', ...
            'LookUnderMasks', 'none' );
        srcportnumber=Saturationconnhandle(i,2);
        [portexists,portnumber] = checkifoutportexists(modelName, blkhandle, srcportnumber );
        if portexists == 1
            newoutportnumber = portnumber;
        else
            newoutportnumber= AddOutport(mainparenthandle,childblockhandle,blkname,srcportnumber,pos,outportstring); % call the function to add outport
        end
        saturate_outportlist(i)= newoutportnumber;                  
    end
    endofoutport_index=newoutportnumber;
    
    for i=1:saturation_count
        strvalue = str2double(get_param(saturation_array{i,1},'LowerLimit'));
        if isnan(strvalue)
            try
                strvalue = get_param(saturation_array{i,1},'LowerLimit');
                saturate_lowlimit(i) = evalin('base', strvalue);
            catch
                error('could not evaluate lower limit of saturate block. please load the variable in base workspace\n')
            end
        else
            saturate_lowlimit(i) = strvalue;
        end
        
        strvalue = str2double(get_param(saturation_array{i,1},'UpperLimit'));
        if isnan(strvalue)
            try
                strvalue = get_param(saturation_array{i,1},'UpperLimit');
                saturate_highlimit(i) = evalin('base', strvalue);
            catch
                error('could not evaluate upper limit of saturate block. please load the variable in base workspace\n')
            end
        else
            saturate_highlimit(i) = strvalue;
        end
    end
    
    % update the output structure
    saturate_block_info(1).conn_handle=Saturationconnhandle;
    saturate_block_info(1).low_threshold=saturate_lowlimit;
    saturate_block_info(1).high_threshold=saturate_highlimit;
    saturate_block_info(1).outport_list=saturate_outportlist;
    saturate_block_info(1).num_of_satblocks=saturation_count;
    saturate_block_info(1).endport_index=endofoutport_index;
    
 end   
    
    
    
    



