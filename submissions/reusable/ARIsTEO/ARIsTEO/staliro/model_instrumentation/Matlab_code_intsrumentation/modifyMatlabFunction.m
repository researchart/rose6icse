% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% 'modifyMatlabFunction' creates a new Simulink model with extra outputs
% correspond to the internal information of the If-Then-Else blocks inside 
% the MATLAB embedded codes.
%
function [new_model]=modifyMatlabFunction(modelName,matlabblockname,numHAs)
    global outputs;
    global branch_lines;
    global else_lines;
    global textIndentation;
    bdclose;
    new_model=save_model_info( modelName );
    load_system(new_model);
    S= sfroot;
    B = S.find('Name',matlabblockname,'-isa','Stateflow.EMChart');
    text=B.Script;
    if ischar(text)
        X=textscan(text,'%s','delimiter',sprintf('\n'));
        textLines=X{1,1};
    end
    sz=size(textLines);
    line =1;
    new_outs=',';
    lo=length(outputs);
    for i=1:lo
        new_outs=strcat(new_outs,'mfo_',int2str(i),',');
    end
    new_outs=strcat(new_outs,'br_1');
    for i=2:numHAs
        new_outs=strcat(new_outs,',br_',int2str(i));
    end
    while line<=sz(1)
        [token, remain]= strtok(textLines{line});
        if(strncmp(token,'%',1))
            line=line+1;
            continue;
        elseif(isempty(regexp(textLines{line},']','ONCE'))==0) 
            index=regexp(textLines{line},']','ONCE');
            text=textLines{line};
            if index>1
                text=strcat(text(1:index-1),new_outs,text(index:end));
            else
                text=strcat(new_outs,text);
            end
            textLines{line}=text;
            break;
        end
        line=line+1;
    end
    text='';
    sz=size(textLines);
    curr_line=1;
    curr_HA=1;
    for i=1:sz(1)
        if curr_line<=length(branch_lines{curr_HA}) && branch_lines{curr_HA}(curr_line)==i
            if curr_line<length(branch_lines{curr_HA})
                text=sprintf('%s%sbr_%d=%d;\n',text,textIndentation{i-1},curr_HA,curr_line);
            end
            if curr_line==length(branch_lines{curr_HA})
                if curr_HA==numHAs 
                    lo=length(outputs);
                    for j=1:lo
                        new_outs=strcat('mfo_',int2str(j),'=',outputs{j},';');
                        text=sprintf('%s%s%s\n',text,textIndentation{i-1},new_outs);
                    end
                else
                    text=sprintf('%s%sbr_%d=%d;\n',text,textIndentation{i-1},curr_HA,curr_line);
                end
            end
            curr_line=curr_line+1;
            if curr_line>length(branch_lines{curr_HA}) && curr_HA<numHAs
                curr_line=1;
                curr_HA=curr_HA+1;
            else
                if else_lines(i)==1 && curr_line<=length(branch_lines{curr_HA}) && branch_lines{curr_HA}(curr_line)==i
                    text=sprintf('%s%selse \n%sbr_%d=%d;\n',text,textIndentation{i},textIndentation{i-1},curr_HA,curr_line);
                    curr_line=curr_line+1;
                    if curr_line>length(branch_lines{curr_HA}) && curr_HA<numHAs
                        curr_line=1;
                        curr_HA=curr_HA+1;
                    end
                end
            end
        end
        text=sprintf('%s%s%s\n',text,textIndentation{i},textLines{i});
    end
    B.Script=text;
    close_system(new_model, 1);
end

