% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ output_string,predicate_table  ] = process_string( bool_string )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    output_string='';
    predicate_table=cell(1,7);
    str_read_index=1;
    %str_write_index=1;
    pred_index=0;
    while(str_read_index<length(bool_string))
        if strcmp(bool_string(str_read_index),'(') && ~strcmp(bool_string(str_read_index+1),'(')
            if str_read_index~=1
                if ( bool_string(str_read_index-1) ~= '(')
                 %str_write_index = str_write_index+1;
                 output_string = strcat(output_string,{' '});
                end
            end
            start_index= str_read_index+1;
            end_index=start_index;
            index=1;
            predicate='';
            while(~strcmp(bool_string(end_index),')'))
                predicate(index)= bool_string(end_index);
                index=index+1;
                end_index=end_index+1;
            end
            table_size=size(predicate_table);
            pred_match_flag=0;
            for i=1: table_size(1)
                if strcmp(predicate,predicate_table{i,1})
                    pred_match_flag=1;
                    for j = 1:length (predicate_table{i,2})
                        output_string = strcat(output_string,predicate_table{i,2});
                        %str_write_index = str_write_index +1;
                    end
                    str_read_index = end_index+1;
%                     str_write_index = str_write_index +1; % space delimiter
                    break;
                end
            end
            if pred_match_flag==0
                %split string at relational operator. "strtok"
                %split first part at 'O' remain will have constant value
                %similarly second part and update string_index= end_index+1;
                pred_index=pred_index+1;
                [str1,str2]=strtok(predicate,['<';'>']);
                [str11,str12]=strtok(str1,'O');
                out_value1 = 0;
                c_value1 = [];
                if strcmp(str1(1),'O')
                    out_value1=str2double(str11);
                    %if isNAN(out_value1)
                        %out_value1 = 0; end
                else
                    c_value1=str2double(str11);
                end
                operator_type= str2(1);
                [str21,str22]=strtok(str2,operator_type);
                out_value2 = 0;
                c_value2 = [];
                if strcmp(str21(1),'O')
                    out_value2=str2double(strtok(str21,'O'));
                else
                    c_value2=str2double(str21);
                end
                
                predicate_symbol = strcat('p',num2str(pred_index));
%                 for i = 1:length (predicate_symbol)
%                     output_string(str_write_index)=predicate_symbol(i);
%                     str_write_index = str_write_index + 1;
%                     str_read_index = str_read_index+1;
%                 end
                output_string = strcat(output_string,predicate_symbol,{' '});
                
                predicate_table{pred_index,1} = predicate;
                predicate_table{pred_index,2} = predicate_symbol;
                predicate_table{pred_index,3} = operator_type;
                predicate_table{pred_index,4} = out_value1;
                predicate_table{pred_index,5} = c_value1;
                predicate_table{pred_index,6} = out_value2;
                predicate_table{pred_index,7} = c_value2;
%                 str_write_index = str_write_index + 1;%for space delimiter
                if end_index < length(bool_string)
                    str_read_index= end_index+1;
                else
                    str_read_index= end_index;
                end
            end

        else
            if (str_read_index~=1 && bool_string(str_read_index) == '(' && bool_string(str_read_index-1) ~= '(')
                %str_write_index = str_write_index + 1; 
                output_string = strcat(output_string,{' '});
            end
%            output_string(str_write_index)= bool_string(str_read_index);
            output_string = strcat(output_string,bool_string(str_read_index));
            %str_write_index = str_write_index + 1; % for space delimiter
            if ( bool_string(str_read_index) == '(' || bool_string(str_read_index) == ')')
                %str_write_index = str_write_index + 1;
                output_string = strcat(output_string,{' '});
            end
            str_read_index=str_read_index+1;
        end
    end
    %output_string(str_write_index) = bool_string(str_read_index);
    if strcmp(output_string{1}(1),'(')
        output_string = strcat(output_string,bool_string(str_read_index));
    end
    if iscell(output_string)
             output_string = cell2mat(output_string);
    end
    output_string=strrep(output_string,'||','|');
end 
