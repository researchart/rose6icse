% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% 'findConditions' is the main function that parses the MATLAB function
% text 'textLines' to find all the If-Then-Else blocks and extracts the 
% information.

function [ ] = findConditions( textLines , numHAs )
    global line;
    global bArray;
    global A_Array;
    global outputs;
    global predNum;
    global guards;
    global branch_lines;
    global else_lines; 
    branch_lines={};
    bArray=[];
	A_Array=[];
    outputs={};
	predNum=0;
    guards={};
    conditionLines={};
    szl=size(textLines);
    else_lines=zeros(szl(1),1);
    line=1;
    currHA=0;
    while line<=szl(1)
        [token, remain]= strtok(textLines{line});
        if(strncmp(token,'if',2))
            else_handled=0;
            conditionLines={};
            currHA=currHA+1;
            if currHA>numHAs
                error('More than expected number of Hybrid Automata is detected');
            end
            sz=size(token);
            if(sz(2)>2)
                token=token(3:end);
                condition=token;
            else
                condition=remain;
            end
            new_condition='';
            while isempty(strfind(condition,'...'))==0
                remain=condition(1:strfind(condition,'...')-1);
                new_condition=remain;
                line=line+1;
                remain=textLines{line};
                new_condition=[new_condition, ' ', remain];
                condition=new_condition;
            end
            if isempty(strfind(condition,'%'))==0
                condition=condition(1:strfind(condition,'%')-1);
            end
            [boolText]=findBooleans(condition);
            conditionLines{1}=boolText;
            [ branch_handled ] = branchIfElse( textLines,boolText,currHA );
            if branch_handled==0
                try
                    branch_lines{currHA}=[branch_lines{currHA}, line];
                catch
                    branch_lines{currHA}=line;
                end
                branch_handled=1;
                bl=length(branch_lines{currHA});
                guards{currHA}{bl}=boolText;
                line=line-1;
            end
        elseif(strncmp(token,'elseif',6))
            sz=size(token);
            if(sz(2)>6)
                token=token(3:end);
                condition=token;
            else
                condition=remain;
            end
            new_condition='';
            while isempty(strfind(condition,'...'))==0
                remain=condition(1:strfind(condition,'...')-1);
                new_condition=remain;
                line=line+1;
                remain=textLines{line};
                new_condition=[new_condition, ' ', remain];
                condition=new_condition;
            end
            if isempty(strfind(condition,'%'))==0
                condition=condition(1:strfind(condition,'%')-1);
            end
            [boolText]=findBooleans(condition);
            if length(conditionLines)==1
                newBoolText=strcat({'! ( '},conditionLines{1},{' ) & ( '},boolText,{' ) '});
            else
                newBoolText= strcat({'! ( '},conditionLines{1},{' ) '});
                for i=2:length(conditionLines)
                    newBoolText= strcat(newBoolText, {' & ! ( '},conditionLines{i},{' )'});
                end
                newBoolText=strcat(newBoolText,{' & (  '},boolText,{' ) '});
            end
            conditionLines{length(conditionLines)+1}=boolText;
            [ branch_handled ] = branchIfElse( textLines,newBoolText, currHA );
            if branch_handled==0
                try
                    branch_lines{currHA}=[branch_lines{currHA}, line];
                catch
                    branch_lines{currHA}=line;
                end
                branch_handled=1;
                bl=length(branch_lines{currHA});
                guards{currHA}{bl}=newBoolText;
                line=line-1;
            end
        elseif(strncmp(token,'else',4))
            if length(conditionLines)==1
                boolText=strcat({'! ( '},boolText,{' )'});
            else
                boolText= strcat({'! ( '},conditionLines{1},{' )'});
                for i=2:length(conditionLines)
                    boolText= strcat(boolText, {' & ! ( '},conditionLines{i},{' )'});
                end
            end
            branch_handled=branchIfElse(textLines,boolText, currHA);
            if branch_handled==0
                try
                    branch_lines{currHA}=[branch_lines{currHA}, line];
                catch
                    branch_lines{currHA}=line;
                end
                branch_handled=1;
                bl=length(branch_lines{currHA});
                guards{currHA}{bl}=boolText;
            end
            else_handled=1;
        elseif(strncmp(token,'end',3))
            if else_handled==0
                if length(conditionLines)==1
                    boolText=strcat({'! ( '},boolText,{' )'});
                else
                    boolText= strcat({'! ( '},conditionLines{1},{' )'});
                    for i=2:length(conditionLines)
                        boolText= strcat(boolText, {' & ! ( '},conditionLines{i},{' )'});
                    end
                end
                try
                    branch_lines{currHA}=[branch_lines{currHA}, line];
                catch
                    branch_lines{currHA}=line;
                end
                branch_handled=1;
                bl=length(branch_lines{currHA});
                guards{currHA}{bl}=boolText;
                else_handled=1;
                else_lines(line)=1;
            end
        end
        line=line+1;
    end
end

