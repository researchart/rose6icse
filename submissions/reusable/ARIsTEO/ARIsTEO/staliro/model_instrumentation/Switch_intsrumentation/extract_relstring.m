% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ relational_string ] = extract_relstring(modelName,blockList,relational_blk,rel_operator)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%     simopt = simget(modelName);
%     simopt = simset(simopt,'SaveFormat','StructureWithTime');
    if strcmp(rel_operator,'<=')
        rel_operator = '<';
    elseif strcmp(rel_operator,'>=')
        rel_operator = '>';
    end
    eval([modelName,'([],[],[],''compile'');']);
    portConn = get_param(blockList(relational_blk), 'PortConnectivity');
    portConn_struct=portConn{1};
    
    relsrchandle1= portConn_struct(1).SrcBlock;
    relsrchandle1_type= get_param(relsrchandle1,'BlockType');
    if strcmp(relsrchandle1_type,'Constant')
        str1= int2str(get_param(relsrchandle1,'Value'));
    else
        relsrc_portt1=  portConn_struct(1).SrcPort;
        port_list=get_param(relsrchandle1,'Ports');
        relsrc_portConn= get_param(relsrchandle1, 'PortConnectivity');
        index= port_list(1)+port_list(2)+relsrc_portt1;
        DstBlock_list=relsrc_portConn(index).DstBlock;
        DstBlock_length= length(relsrc_portConn(index).DstBlock);
        %str1='';
        for i_Dst=1: DstBlock_length
            DstBlock_type= get_param(DstBlock_list(i_Dst),'BlockType');
            if strcmp(DstBlock_type, 'Outport')
                portname = get_param(DstBlock_list(i_Dst),'Name');
                str1=strcat('O',get_param(strcat(modelName,'/',portname),'Port')); %added outport
                break;
            end
        end
    end
    %repeat for second connection
    
%     portConn = get_param(blockList(relational_blk), 'PortConnectivity');
%     portConn_struct=portConn{1};
    relsrchandle2= portConn_struct(2).SrcBlock;
    relsrchandle2_type= get_param(relsrchandle2,'BlockType');
    if strcmp(relsrchandle2_type,'Constant')
        str2= get_param(relsrchandle2,'Value');
        if isnan(str2double(str2))
           try
                intstr2 = evalin('base', str2);
                str2= num2str(intstr2);
           catch
                    error('could not evaluate threshold of switch block. please load the variable in base workspace\n')
           end
        end
    else
        relsrc_portt2=  portConn_struct(2).SrcPort;
        port_list=get_param(relsrchandle2,'Ports');
        relsrc_portConn= get_param(relsrchandle2, 'PortConnectivity');
        index= port_list(1)+port_list(2)+relsrc_portt2;
        DstBlock_list=relsrc_portConn(index).DstBlock;
        DstBlock_length= length(relsrc_portConn(index).DstBlock);
        %str1='';
        for i_Dst=1: DstBlock_length
            DstBlock_type= get_param(DstBlock_list(i_Dst),'BlockType');
            if strcmp(DstBlock_type, 'Outport')
                portname = get_param(DstBlock_list(i_Dst),'Name');
                str2=strcat('O',get_param(strcat(modelName,'/',portname),'Port'));
                %str2=strcat('O',get_param(DstBlock_list(i_Dst),'Port')); %added outport
                break;
            end
        end
    end
    eval([modelName,'([],[],[],''term'');']);

    relational_string=strcat('(',str1,rel_operator,str2,')');
end

