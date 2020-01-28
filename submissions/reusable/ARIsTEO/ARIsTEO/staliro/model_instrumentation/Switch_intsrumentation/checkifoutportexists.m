% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ portexists,portnumber ] = checkifoutportexists(modelName, srcblk,srcprt )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    portexists = 0;
    portnumber = 0;
    eval([modelName,'([],[],[],''compile'');']);
%     portConn = get_param(relational_blk, 'PortConnectivity');
%     portConn_struct=portConn{1};
%     
%     relsrchandle1= portConn_struct(1).SrcBlock;
%     %relsrchandle1_type= get_param(relsrchandle1,'BlockType');
%     relsrc_portt1=  portConn_struct(1).SrcPort;
    
    relsrchandle1 = srcblk;
    relsrc_portt1 = srcprt;
    port_list=get_param(relsrchandle1,'Ports');
    relsrc_portConn= get_param(relsrchandle1, 'PortConnectivity');
    index= port_list(1)+relsrc_portt1;% + port_list(2);
    DstBlock_list=relsrc_portConn(index).DstBlock;
    DstBlock_length= length(relsrc_portConn(index).DstBlock);
    %str1='';
    for i_Dst=1: DstBlock_length
        DstBlock_type= get_param(DstBlock_list(i_Dst),'BlockType');
        if strcmp(DstBlock_type, 'Outport')
            portname = get_param(DstBlock_list(i_Dst),'Name');
            %str1=strcat('O',get_param(strcat(modelName,'/',portname),'Port')); %added outport
            portnumber = str2double(get_param(strcat(modelName,'/',portname),'Port'));
            portexists = 1;
            break;
        end
    end
   eval([modelName,'([],[],[],''term'');']); 
end

