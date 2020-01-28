% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% 'findBooleans' extracts the boolean formula from the If-Then-Else 
% conditions. This function creates the predicates of the boolean formulas
% based on the condition. Each predicate corresponds to an inequality of
% the branch conditions. This function also creates the corresponding A,b
% matrices for each predicate.

function [boolText]=findBooleans(condition)
    global bArray;
    global A_Array;
    global outputs;
    global predNum;
    patternBool='&&|\|\||~(|~\s';
    prefixText='';
    suffixText='';
    paranthesText='';
    boolOps=regexp(condition,patternBool);
    if isempty(boolOps)==0
        sz=length(boolOps);
        predText=cell(sz+1,1);
        boolOpText=cell(sz,1);
        predText{1}=condition(1:boolOps(1)-1);
        for i=1:length(boolOps)
            if(condition(boolOps(i))=='&'||condition(boolOps(i))=='|')
                boolOpText{i}=condition(boolOps(i));
                start=2;
            elseif(condition(boolOps(i))=='~')
                boolOpText{i}='!';
                start=1;
            else
                error('operations of && , || , ~ , are expected');
            end
            if i<length(boolOps)
                predText{i+1}=condition(boolOps(i)+start:boolOps(i+1)-1);
            else
                predText{i+1}=condition(boolOps(i)+start:end);
            end
        end
        patternParanthes=')|(';
        for i=1:length(boolOps)+1
            tempText=char(predText(i));
            paranthesis=regexp(tempText,patternParanthes);
            if isempty(paranthesis)==0
                S = Stack(length(paranthesis));
                parClose=0;
                for j=1:length(paranthesis)
                    if S.IsEmpty()==1 && tempText(paranthesis(j))==')'
                        parClose=j;
                        break
                    else
                        if tempText(paranthesis(j))=='('
                            S.Push(tempText(paranthesis(j)));
                        elseif tempText(paranthesis(j))==')'
                            top=char(S.Pop());
                            if top==')'
                                error('Error on pranthesis');
                            end
                        end
                    end
                end
                if S.IsEmpty()==0
                    startIndex=paranthesis(S.Count())+1;
                    predText{i}=tempText(startIndex:end);
                    paranthesText=tempText(1:startIndex-1);
                    if i==1
                        prefixText=paranthesText;
                    else
                        boolOpText{i-1}=strcat(boolOpText{i-1},{' '},paranthesText);
                    end
                elseif parClose>0
                    endIndex=paranthesis(parClose)-1;
                    predText{i}=tempText(1:endIndex);
                    paranthesText=tempText(endIndex+1:end);
                    if i<=length(boolOps)
                        boolOpText{i}=strcat(paranthesText,{' '},boolOpText{i});
                    else
                        suffixText=paranthesText;
                    end                    
                end
                S.Clear();
            end
        end
    else
        predText{1}=condition;
    end
    boolText='';
    boolText=strcat(boolText,prefixText);
    patternRelation='<=|<|>=|>';
    for i=1:length(boolOps)+1
        token=predText{i};
        relatOps=regexp(token,patternRelation);
        if isempty(relatOps)==1
            if i<=length(boolOps)
                boolText=strcat(boolText,{' '},boolOpText{i});
            end
            continue;
        end
        lo=length(outputs);
        lo=lo+1;
		predNum=predNum+1;
        boolText=strcat(boolText,{' '},'p',int2str(predNum));
        boolText=strcat(boolText,{' '});
        if i<=length(boolOps)
            boolText=strcat(boolText,{' '},boolOpText{i});
        end
        if( isempty(findstr(token, '~='))~=1 || isempty(findstr(token, '=='))~=1 )
            error('only operations of <= , < , > , >= are supported');
        else
            loc = findstr(token, '<=');
            if isempty(loc)~=1
                textL=token(1:loc-1);
                realL=str2double(textL);
                textR=token(loc+2:end);
                realR=str2double(textR);
                if( isnan(realL)==1 && isnan(realR)==1 )
                    text=strcat(textL,' - ',textR);
                    try    
                        bArray=[bArray,0];
                    catch
                        bArray=0;
                    end
                    try    
                        A_Array=[A_Array,lo];
                    catch
                        A_Array=lo;
                    end
                elseif( isnan(realL)~=1 )
                    try    
                        bArray=[bArray,-realL];
                    catch
                        bArray=-realL;
                    end
                    if isempty(find(strcmp(outputs,strtrim(textR))))==0
                        index=find(strcmp(outputs,strtrim(textR)));
                        try    
                            A_Array=[A_Array,-index];
                        catch
                            A_Array=-index;
                        end
                        continue;
                    end
                    text=textR;
                    try    
                        A_Array=[A_Array,-lo];
                    catch
                        A_Array=-lo;
                    end                        
                elseif( isnan(realR)~=1 )
                    try    
                        bArray=[bArray,realR];
                    catch
                        bArray=realR;
                    end
                    if isempty(find(strcmp(outputs,strtrim(textL))))==0
                        index=find(strcmp(outputs,strtrim(textL)));
                        try    
                            A_Array=[A_Array,index];
                        catch
                            A_Array=index;
                        end
                        continue;
                    end
                    text=textL;
                    try    
                        A_Array=[A_Array,lo];
                    catch
                        A_Array=lo;
                    end
                end
                outputs{lo}=strtrim(text);
                continue;
            end
            loc = findstr(token, '<');
            if isempty(loc)~=1
                textL=token(1:loc-1);
                realL=str2double(textL);
                textR=token(loc+1:end);
                realR=str2double(textR);
                if( isnan(realL)==1 && isnan(realR)==1 )
                    text=strcat(textL,' - ',textR);
                    try    
                        bArray=[bArray,0];
                    catch
                        bArray=0;
                    end
                    try    
                        A_Array=[A_Array,lo];
                    catch
                        A_Array=lo;
                    end
                elseif( isnan(realL)~=1 )
                    try    
                        bArray=[bArray,-realL];
                    catch
                        bArray=-realL;
                    end
                    if isempty(find(strcmp(outputs,strtrim(textR))))==0
                        index=find(strcmp(outputs,strtrim(textR)));
                        try    
                            A_Array=[A_Array,-index];
                        catch
                            A_Array=-index;
                        end
                        continue;
                    end
                    text=textR;
                    try    
                        A_Array=[A_Array,-lo];
                    catch
                        A_Array=-lo;
                    end
                elseif( isnan(realR)~=1 )
                    try 
                        bArray=[bArray,realR];
                    catch    
                        bArray=realR;
                    end
                    if isempty(find(strcmp(outputs,strtrim(textL))))==0
                        index=find(strcmp(outputs,strtrim(textL)));
                        try    
                            A_Array=[A_Array,index];
                        catch
                            A_Array=index;
                        end
                        continue;
                    end
                    text=textL;
                    try    
                        A_Array=[A_Array,lo];
                    catch
                        A_Array=lo;
                    end
                end
                outputs{lo}=strtrim(text);
                continue;
            end
            loc = findstr(token, '>=');
            if isempty(loc)~=1
                 textL=token(1:loc-1);
                 realL=str2double(textL);
                 textR=token(loc+2:end);
                 realR=str2double(textR);
                 if( isnan(realL)==1 && isnan(realR)==1 )
                     text=strcat(textR,' - ',textL);
                     try    
                         bArray=[bArray,0];
                     catch
                         bArray=0;
                     end
                     try    
                         A_Array=[A_Array,lo];
                     catch
                         A_Array=lo;
                     end
                 elseif( isnan(realL)~=1 )
                     try    
                         bArray=[bArray,realL];
                     catch
                         bArray=realL;
                     end
                     if isempty(find(strcmp(outputs,strtrim(textR))))==0
                         index=find(strcmp(outputs,strtrim(textR)));
                         try    
                             A_Array=[A_Array,index];
                         catch
                             A_Array=index;
                         end
                         continue;
                     end
                     text=textR;
                     try    
                         A_Array=[A_Array,lo];
                     catch
                         A_Array=lo;
                     end
                 elseif( isnan(realR)~=1 )
                     try    
                         bArray=[bArray,-realR];
                     catch
                         bArray=-realR;
                     end                     
                     if isempty(find(strcmp(outputs,strtrim(textL))))==0
                         index=find(strcmp(outputs,strtrim(textL)));
                         try    
                             A_Array=[A_Array,-index];
                         catch
                             A_Array=-index;
                         end
                         continue;
                     end
                     text=textL;
                     try    
                         A_Array=[A_Array,-lo];
                     catch
                         A_Array=-lo;
                     end
                 end
                 outputs{lo}=strtrim(text);
                 continue;
            end
                
                 loc = findstr(token, '>');
                 if isempty(loc)~=1
                     textL=token(1:loc-1);
                     realL=str2double(textL);
                     textR=token(loc+1:end);
                     realR=str2double(textR);
                     if( isnan(realL)==1 && isnan(realR)==1 )
                         text=strcat(textR,' - ',textL);
                         try    
                             bArray=[bArray,0];
                         catch
                             bArray=0;
                         end
                         try    
                             A_Array=[A_Array,lo];
                         catch
                             A_Array=lo;
                         end
                     elseif( isnan(realL)~=1 )
                         try    
                             bArray=[bArray,realL];
                         catch
                             bArray=realL;
                         end
                         if isempty(find(strcmp(outputs,strtrim(textR))))==0
                             index=find(strcmp(outputs,strtrim(textR)));
                             try    
                                 A_Array=[A_Array,index];
                             catch
                                 A_Array=index;
                             end
                             continue;
                         end                        
                         text=textR;
                         try    
                             A_Array=[A_Array,lo];
                         catch
                             A_Array=lo;
                         end
                     elseif( isnan(realR)~=1 )
                         try    
                             bArray=[bArray,-realR];
                         catch
                             bArray=-realR;
                         end
                         if isempty(find(strcmp(outputs,strtrim(textL))))==0
                             index=find(strcmp(outputs,strtrim(textL)));
                             try    
                                 A_Array=[A_Array,-index];
                             catch
                                 A_Array=-index;
                             end
                             continue;
                         end                        
                         text=textL;
                         try    
                             A_Array=[A_Array,-lo];
                         catch
                             A_Array=-lo;
                         end
                     end
                     outputs{lo}=strtrim(text);
                     continue;
                 end
         end
    end
    boolText=strcat(boolText,suffixText);
end

