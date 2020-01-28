% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ A_cell,b_cell,proj_cell ] = DNF_CLG( DNF_string, predicate_table,guardsize,projection_mode )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    A_cell = {};
    b_cell = {};
    proj_cell = {};
    cell_index = 1;
    [token_or, remain_or] = strtok(DNF_string,'|');
    while ~isempty(token_or) 
        A = [];
        proj = [];
        b = [];
        [token_and, remain_and] = strtok(token_or,'&');
        while ~isempty(token_and)
            [token_and] = strtok(token_and,['(',')']);
            not_pred = 0;
            if token_and(1)=='!'
                not_pred = 1;
                [token_and] = strtok(token_and,'!');
            end
            [token_and,temp] = strtok(token_and,'p');
            if ~isempty(temp)
                error('invalid string');
            end
            predicate_table_index = str2double(token_and);
            if projection_mode == 0
                A_temp = zeros(1,guardsize);
            else
                A_temp = [];
            end
            proj_temp = [];
            %b_temp = [];
            if predicate_table{predicate_table_index,3}=='<'
                if not_pred ==1
                    if projection_mode == 0
                        A_temp(1,predicate_table{predicate_table_index,4})= -1;
                    else
                         A_temp(1,1)= -1;
                         proj_temp(1,1) = predicate_table{predicate_table_index,4};
                    end
                else
                    if projection_mode == 0
                        A_temp(1,predicate_table{predicate_table_index,4})= 1;
                    else
                        A_temp(1,1)= 1;
                        proj_temp(1,1) = predicate_table{predicate_table_index,4};
                    end
                end
                if predicate_table{predicate_table_index,6}~=0
                    if not_pred ==1
                        if projection_mode == 0
                            A_temp(1,predicate_table{predicate_table_index,6})= 1;
                        else
                            A_temp(1,2) = 1;
                            proj_temp(1,2) = predicate_table{predicate_table_index,6};
                        end
                    else
                        if projection_mode == 0
                            A_temp(1,predicate_table{predicate_table_index,6})= -1;
                        else
                            A_temp(1,2) = -1;
                            proj_temp(1,2) = predicate_table{predicate_table_index,6};
                        end
                    end
                     b_temp = 0;   
                else
                    if not_pred ==1
                        b_temp=-1*predicate_table{predicate_table_index,7};
                    else
                        b_temp=[predicate_table{predicate_table_index,7}];
                    end
                end
            else
                if not_pred ==1
                    if projection_mode == 0
                        A_temp(1,predicate_table{predicate_table_index,4})= 1;
                    else
                        A_temp(1,1)= 1;
                        proj_temp(1,1) = predicate_table{predicate_table_index,4};
                    end
                else
                    if projection_mode == 0
                        A_temp(1,predicate_table{predicate_table_index,4})= -1;
                    else
                        A_temp(1,1)= -1;
                        proj_temp(1,1) = predicate_table{predicate_table_index,4};
                    end
                end
                if predicate_table{predicate_table_index,6}~=0
                    if not_pred ==1
                        if projection_mode == 0
                            A_temp(1,predicate_table{predicate_table_index,6})= -1;
                        else
                            A_temp(1,2)= -1;
                            proj_temp(1,2) = predicate_table{predicate_table_index,6};
                        end
                    else
                        if projection_mode == 0
                            A_temp(1,predicate_table{predicate_table_index,6})= 1;
                        else
                            A_temp(1,2)= 1;
                            proj_temp(1,2) = predicate_table{predicate_table_index,6};
                        end
                    end
                    b_temp = 0;
                else
                    if not_pred ==1
                        b_temp = predicate_table{predicate_table_index,7};
                    else 
                        b_temp=-1*predicate_table{predicate_table_index,7};
                    end
                end
            end
            A= [A ;A_temp];
            proj = [proj;proj_temp];
            b = [b;b_temp];
            [token_and, remain_and] = strtok(remain_and,'&');
        end
        A_cell{1,cell_index}= A;
        b_cell{1,cell_index}= b;
        if projection_mode == 1
            proj_cell{1,cell_index} = proj;
        end
        cell_index = cell_index+1;
        [token_or, remain_or] = strtok(remain_or,'|');
    end
end



