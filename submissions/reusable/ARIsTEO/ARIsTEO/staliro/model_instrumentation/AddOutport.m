% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function[newoutportnumber]= AddOutport(mainparenthandle,childblockhandle,blkname,srcportnumber,pos,outportstring)
  % Add outports until we reach the upper most layer of the model 
    %global newoutportnumber;
    %newoutportnumber=0;
    
    % need to add a check for already existing output port. If outport already
    % exists then need return that outport number. Dont need to add again.
    while(mainparenthandle~=get_param(get_param(childblockhandle,'Parent'),'Handle'))
        
        syst=get_param(childblockhandle, 'Parent');
        
        %handlecheck=add_block('built-in/Outport',[syst '/Out-1'],'MakeNameUnique','on','Position',pos);
        handlecheck=add_block('built-in/Outport',[syst '/' outportstring],'MakeNameUnique','on','Position',pos);
        
        %need to some how get the correct outport number of blkname -"Ports". 
        % it is assumed that when new outport added then it has the last port number 
        % For ex: if nomber of outport is 3, then the newly added outport
        % will be 3. Use Ports command
        %"Ports"-vector that specifies number of each kind of port block has.
        
        blknamedetail=get_param(strcat(syst,'/',blkname),'Ports');
        outportnumber=blknamedetail(1,2);
        if (srcportnumber < outportnumber)
            outportnumber=srcportnumber;
        end
        
        
        add_line ([syst '/'], [blkname '/' int2str(outportnumber)], [outportstring '/1'],'autorouting', 'on');
        
        % Update blkname and childblockhandle to move up and outport to next higher level 
        blkname= get_param(get_param(childblockhandle,'Parent'), 'Name');
        %%%%%%%%%%
        Parent_handle=get_param(get_param(childblockhandle,'Parent'),'Handle');
        blknamedetail=get_param(Parent_handle,'Ports');
        srcportnumber=blknamedetail(1,2);
        %%%%%%%%%%%
        childblockhandle=get_param(get_param(childblockhandle,'Parent'), 'Handle');
        
        newoutportnumber = AddOutport(mainparenthandle,childblockhandle,blkname,srcportnumber,pos,outportstring);
        return
    end
    % When reached the upper most layer, add outport at this level and exit
    
    syst=get_param(mainparenthandle, 'Name');
    newporthandle=add_block('built-in/Outport',[syst '/' outportstring],'MakeNameUnique','on','Position',pos);
    nameofnewport=get_param(newporthandle,'Name');
    blknamedetail=get_param(strcat(syst,'/',blkname),'Ports');
    outportnumber=blknamedetail(1,2);
    if (srcportnumber < outportnumber)
       outportnumber=srcportnumber;
    end
    add_line (syst, [blkname '/' int2str(outportnumber)], [nameofnewport '/1'],'autorouting', 'on');
    
    newoutportnumber=str2double(get_param(newporthandle,'Port'));
end



