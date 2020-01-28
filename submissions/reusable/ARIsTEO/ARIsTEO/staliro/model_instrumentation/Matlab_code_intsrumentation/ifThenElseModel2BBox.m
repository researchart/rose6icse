% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% ifThenElseModel2BBox function extracts the branch conditions of Simulink 
% blocks with Matlab embedded code. ifThenElseModel2BBox instruments the 
% If-Then-Else blocks of the MATLAB embedded code (MATLAB function block). 
% 
% For ifThenElseModel2BBox(modelName,matlabblockname), two parameters are 
% needed: 
% 'modelName' is the name of the Simulink model.
% 'matlabblockname' is the name of MATLAB embedded code (MATLAB function 
% block) inside the Simulink model. 
%
% One If-Then-Else block is modeled with two state Hybrid Automata. 
% Nested If-Then-Else blocks are modeled with more than two states. 
%
% 'ifThenElseModel2BBox' creates a new Simulink model with extra outputs.
% The extra outputs help us to observe the internal computation of the
% MATLAB embedded code. 
% 
% The output is the Black Box model 'BBmodel'. This is an S-TaLiRo object 
% where the If-Then-Else are simulated through Hybrid Automata. The number 
% of states and guard conditions for each Hybrid Automata correspond to 
% the internal decisions of the If-Then-Else blocks. For more information 
% about S-TaLiRo Black Box run:
%
% >> help staliro_blackbox
% 
%
%  Copyright (c) 2017  Georgios Fainekos - ASU	
%  Copyright (c) 2017  Adel Dokhanchi - ASU		
%
function [BBmodel] = ifThenElseModel2BBox(modelName,matlabblockname)
    global bArray;
    global A_Array;
    global outputs;
    global guards;
    global branch_lines;
    global textIndentation;
    bdclose all;
    if( isempty(modelName)==0 )
        load_system(modelName);
        S= sfroot;
        handle = S.find('Name',matlabblockname,'-isa','Stateflow.EMChart');
        block_model_path=handle.Path;
        text=handle.Script;
        if ischar(text)
            X=textscan(text,'%s','delimiter',sprintf('\n'));
            % For adding indentation
            Y=textscan(text, '%s', 'delimiter', '\n', 'whitespace', '');
            textLines=X{1,1};
            textIndentation=Y{1,1};
        end
        sz=size(textLines);
        for i=1:sz
            j=strfind(textIndentation{i},textLines{i});
            if(j>1)
                textIndentation{i}=textIndentation{i}(1:j-1);
            else
                textIndentation{i}='';
            end
        end
        outport_array = find_system(modelName,'SearchDepth',1,'BlockType','Outport');
        outPortNum = length(outport_array);
        lastpos=get_param(outport_array{outPortNum},'Position');
        [ifLines,fcn_end]=findNumberOfHAs( textLines );
        numHAs=length(ifLines);
%        syst=get_param(modelName, 'Name');
        blknamedetail0=get_param(block_model_path,'Ports');
        findConditions( textLines , numHAs);
        DNFs={};
        for j=1:numHAs
            sz=length(guards{j});
            for i=1:sz
                string=guards{j}{i};
                DNFs{j}{i}=boolean2dnf(char(string));
            end
        end
        branch_lines{numHAs}=[branch_lines{numHAs},fcn_end];
        [new_model]=modifyMatlabFunction(modelName,matlabblockname,numHAs);
        open_system(new_model);
        syst=get_param(new_model, 'Name');
        block_model_path2=strcat(syst,block_model_path((length(modelName)+1):end));
        fcn_block_name=block_model_path((length(modelName)+2):end);
%        blknamedetail1=get_param(block_model_path2,'Ports');
        blockPos=get_param(block_model_path2,'Position');
        blockPos(1)=blockPos(3)+100;
        blockPos(2)=blockPos(4)+100;
        blockPos(3)=blockPos(1)+40;
        blockPos(4)=blockPos(2)+20;
        syst=get_param(new_model, 'Name');
        lo=length(outputs);
        for j=1:lo
            blockPos=blockPos+[0 30 0 30];
            new_outs=strcat('/MFO_',int2str(j));
            nameOfNewGoto=strcat('MFO_',int2str(j),'_GoTo');
            outportnumber=blknamedetail0(1,2)+j;
            if isequal(fcn_block_name,matlabblockname)==1
                add_block('built-in/Goto', [syst,'/', nameOfNewGoto],'MakeNameUnique','on', 'Position', blockPos, 'GotoTag', nameOfNewGoto, 'TagVisibility', 'global', 'ShowName', 'off');
                add_line (syst, [fcn_block_name '/' int2str(outportnumber)], [nameOfNewGoto '/1'],'autorouting', 'on');
            else
                address=fcn_block_name(1:(length(fcn_block_name)-length(matlabblockname)-1));
                add_block('built-in/Goto', [syst,'/',address,'/', nameOfNewGoto],'MakeNameUnique','on', 'Position', blockPos, 'GotoTag', nameOfNewGoto, 'TagVisibility', 'global', 'ShowName', 'off');                   
                add_line ([syst,'/',address], [matlabblockname '/' int2str(outportnumber)], [nameOfNewGoto '/1'],'autorouting', 'on');
            end
            nameOfNewFrom=strcat('MFO_',int2str(j),'_From');
            lastpos=lastpos+[0 30 0 30];
            add_block('built-in/From', [syst,'/', nameOfNewFrom],'MakeNameUnique','on', 'Position', lastpos, 'GotoTag', nameOfNewGoto, 'TagVisibility', 'global', 'ShowName', 'off');
            newPorthandle=add_block('built-in/Outport',[syst new_outs],'MakeNameUnique','on','Position',(lastpos+[90 0 90 0]));
            nameofPort=get_param(newPorthandle,'Name');
            add_line (syst, [nameOfNewFrom '/1'], [nameofPort '/1'],'autorouting', 'on');
        end
        for j=1:numHAs
            blockPos=blockPos+[0 30 0 30];
            new_outs=strcat('/BR_',int2str(j));
            nameOfNewGoto=strcat('BR_',int2str(j),'_GoTo');
            outportnumber=blknamedetail0(1,2)+j+lo;
            if isequal(fcn_block_name,matlabblockname)==1
                add_block('built-in/Goto', [syst,'/', nameOfNewGoto],'MakeNameUnique','on', 'Position', blockPos, 'GotoTag', nameOfNewGoto, 'TagVisibility', 'global', 'ShowName', 'off');
                add_line (syst, [fcn_block_name '/' int2str(outportnumber)], [nameOfNewGoto '/1'],'autorouting', 'on');
            else
                address=fcn_block_name(1:(length(fcn_block_name)-length(matlabblockname)-1));
                add_block('built-in/Goto', [syst,'/',address,'/', nameOfNewGoto],'MakeNameUnique','on', 'Position', blockPos, 'GotoTag', nameOfNewGoto, 'TagVisibility', 'global', 'ShowName', 'off');                   
                add_line ([syst,'/',address], [matlabblockname '/' int2str(outportnumber)], [nameOfNewGoto '/1'],'autorouting', 'on');
            end
            nameOfNewFrom=strcat('BR_',int2str(j),'_From');
            lastpos=lastpos+[0 30 0 30];
            add_block('built-in/From', [syst,'/', nameOfNewFrom],'MakeNameUnique','on', 'Position', lastpos, 'GotoTag', nameOfNewGoto, 'TagVisibility', 'global', 'ShowName', 'off');
            newPorthandle=add_block('built-in/Outport',[syst new_outs],'MakeNameUnique','on','Position',(lastpos+[90 0 90 0]));
            nameofPort=get_param(newPorthandle,'Name');
            add_line (syst, [nameOfNewFrom '/1'], [nameofPort '/1'],'autorouting', 'on');
        end
        BBmodel=script2BBox(matlabblockname,syst,A_Array,bArray,DNFs,outPortNum,numHAs);
        close_system(new_model,1);
    else
        error('please specify the name of the matlab model without extention');
    end
end