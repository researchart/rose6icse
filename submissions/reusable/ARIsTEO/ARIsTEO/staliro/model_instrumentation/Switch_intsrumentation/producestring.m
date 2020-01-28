% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function boolstr=producestring(modelName,blockList,bool_blocklist,bool_conn_matrix,boolsourceblock,initialpos)    
     %global bool_final;
     %global boolstring;
     %boolstr='';
     sourcetype=cell2mat(get_param(blockList(boolsourceblock), 'blockType'));
     %sourceop= cell2mat(get_param(blockList(boolsourceblock), 'Operator'));
    % base case
    if (strcmp(sourcetype , 'RelationalOperator'))
        sourceop= cell2mat(get_param(blockList(boolsourceblock), 'Operator'));
        boolstr=extract_relstring(modelName,blockList,boolsourceblock,sourceop);
        %boolstr=strcat('(','O1',sourceop,'O2',')');
        return;
    %currently constants not considered. so just return empty. constants
    %are just used in models to hard code values. For ex: for an AND block
    %one of the input is given as 1 so other predicate decide the o/p of
    %AND. So it is fine to ignore constants for now.
    elseif (strcmp(sourcetype , 'Constant'))
        boolstr='';
        return;
    else % recurse
     %rel_connection=0;
     bool_temp={};
     %count=0;
     sourceop= cell2mat(get_param(blockList(boolsourceblock), 'Operator'));
         for i= 1:length(bool_conn_matrix) 
            if (bool_conn_matrix(i,initialpos)~=0)
                foundconnection=1;
                newboolsourceblock=bool_blocklist(i);
                newinitialpos=i;
                %new_sourcetype=get_param(blockList(newboolsourceblock), 'blockType');
                operand= getbooloperand(sourceop);
                if (~isempty(bool_temp))
                    bool_temp= strcat(bool_temp,operand,producestring(modelName,blockList,bool_blocklist,bool_conn_matrix,newboolsourceblock,newinitialpos));
                else
                    bool_temp=producestring(modelName,blockList,bool_blocklist,bool_conn_matrix,newboolsourceblock,newinitialpos);
                end             
            end
         end
         boolstr=strcat({'('},bool_temp,')');
         if iscell(boolstr)
             boolstr = cell2mat(boolstr);
         end
         return;
    end
end
 
function operand= getbooloperand(operand_type)
    %operand= get_param(blockList(newboolsourceblock), 'Operator');
    switch operand_type
        case 'OR'
            operand = {'||'};
        case 'AND'
            operand ={'&&'};
        case 'EXOR'
            operand = '^';
        case 'NOT'
            operand = '!';
        otherwise
            error('producestring: boolean operator not supported.');
    end
end
