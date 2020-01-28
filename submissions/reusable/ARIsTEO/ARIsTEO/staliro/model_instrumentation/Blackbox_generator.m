% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ bbox_filename ] = Blackbox_generator( switch_block_info,saturate_block_info,CLG,modelname,New_Modelname,projection_mode)
% Generates the .m blackbox file to intereface with S-Taliro.
%
% Inputs:
%	switch_block_info - information of the switch blocks obtained from
%	Switch_instrument. Refer to Switch_Instrument for details.
%	saturate_block_info - information of the saturate blocks obtained from
%   Saturate_Instrument. Refer to Saturate_Instrument for details.
%   CLG - Hybrid Automata representation for switch and saturate blocks
%   obtained from Control_Graph.
%   modelname - simulink model name to be instrumented
%   New_Modelname - modified simulink model name after instrumentation 
%
% Outputs:
%   bbox_filename - filename of the .m blackbox file generated.

%%
switchdouble_info = switch_block_info.double_blocks;
boolswitch = switch_block_info.num_of_boolsw;
doubleswitch = switch_block_info.num_of_doublesw;
switch_count = boolswitch+doubleswitch;
LT_float = switch_block_info.LT_float;
LT_bool = switch_block_info.LT_bool;
LT_remove = switch_block_info.LT_remove;

saturation_count = saturate_block_info.num_of_satblocks;
sat_endport_index= saturate_block_info.endport_index;
if saturation_count~=0
    sat_startport_index = sat_endport_index + 1 - saturation_count;
else 
    sat_startport_index = 0;
end
total_count = switch_count+ saturation_count;
c = CLG;

if doubleswitch ~= 0
    double_out_endindex = switchdouble_info(doubleswitch).outportindex;
end

if boolswitch == 0
    if doubleswitch == 0
        guardsize = sat_endport_index;
        endofoutports = sat_endport_index;
    else
        guardsize = double_out_endindex;
        endofoutports = double_out_endindex;
    end
else
    guardsize = switch_block_info.numport_index;
    endofoutports = switch_block_info.endport_index;
end

%projection_mode = 1;
%%
switchdouble_info_filtered = struct('threshold',[],'criteria','','outportindex',[]);
i_count = 0;
switch_threshold_mat = [];
switch_criteria_mat = [];
for i_doublesw = 1:length(switchdouble_info)
    if~isempty(switchdouble_info(i_doublesw).threshold)
        i_count = i_count+1;
        if i_count==1
            doubleport_start_index =  switchdouble_info(i_doublesw,1).outportindex;
        end 
        switchdouble_info_filtered(i_count) = switchdouble_info(i_doublesw);
        switch_threshold_mat(i_count) = switchdouble_info(i_doublesw).threshold;
        if strcmp(switchdouble_info(i_doublesw).criteria,'>=')
            switch_criteria_mat(i_count) = 1;
        else
            switch_criteria_mat(i_count) = 2;
        end
    end
end
if ~(doubleswitch == 0)
    doubleport_end_index = switchdouble_info_filtered(i_count).outportindex;
end
%%
bb_filename = strcat('BlackBox_',modelname);
str{1,1} = sprintf('function [T, XT, YT, LT, clg, grd] = %s(X0,simT,TU,U)',bb_filename);

%strinit{1,1}='LT = [];';
%strinit{2,1}=sprintf('c(1,%d)=CtrlGrph;',total_count);
strinit{1,1} = sprintf('clg=cell(1,%d);',total_count);
strinit{2,1} = sprintf('grd=cell(1,%d);',total_count);

string_sw{1,1} = ''; % to print values of structure c

% write the guards and adjacency matrix to black box file
j=1;
for i = 1:switch_count %length(c)-1
    %for j=6*(i-1)+1:6*i
        %j = 10*(i-1)+1;  
        string_sw{j,1} = 'adj = cell(0);'; 
        j=j+1;
        string_sw{j,1} = sprintf('adj{1}=[%d];',c(i).adj{1}); 
        j=j+1;
        string_sw{j,1} = sprintf('adj{2}=[%d];',c(i).adj{2}); 
        j=j+1;
        string_sw{j,1} = sprintf('clg{%d}=adj;',i); 
        j=j+1;
        if iscell(c(i).grd(1,2).A) && iscell(c(i).grd(2,1).b)
            string_sw{j,1} = 'guards = {};';
            j=j+1;
            [row_size,col_size] = size(c(i).grd(1,2).A);
            for r_iter = 1:row_size
                for c_iter = 1:col_size
                    string_sw{j,1} = sprintf('guards(1,2).A{%d,%d} = %s;',r_iter,c_iter,mat2str(c(i).grd(1,2).A{r_iter,c_iter}));
                    j=j+1;
                    string_sw{j,1} = sprintf('guards(1,2).b{%d,%d} = %s;',r_iter,c_iter,mat2str(c(i).grd(1,2).b{r_iter,c_iter}));
                    j=j+1;
                    if projection_mode == 1
                        string_sw{j,1} = sprintf('guards(1,2).proj{%d,%d} = %s;',r_iter,c_iter,mat2str(c(i).grd(1,2).proj{r_iter,c_iter}));
                        j=j+1;
                    end
                end
            end
            [row_size,col_size] = size(c(i).grd(2,1).A);
            for r_iter = 1:row_size
                for c_iter = 1:col_size
                    string_sw{j,1} = sprintf('guards(2,1).A{%d,%d} = %s;',r_iter,c_iter,mat2str(c(i).grd(2,1).A{r_iter,c_iter}));
                    j=j+1;
                    string_sw{j,1} = sprintf('guards(2,1).b{%d,%d} = %s;',r_iter,c_iter,mat2str(c(i).grd(2,1).b{r_iter,c_iter}));
                    j=j+1;
                    if projection_mode == 1
                        string_sw{j,1} = sprintf('guards(2,1).proj{%d,%d} = %s;',r_iter,c_iter,mat2str(c(i).grd(2,1).proj{r_iter,c_iter}));
                        j=j+1;
                    end
                end
            end
            string_sw{j,1} = sprintf('grd{%d}=guards;',i);
            j=j+1;
        else
            string_sw{j,1} = 'guards = [];'; 
            j=j+1;
            %end
            string_sw{j,1} = sprintf('guards(1,2).b = %s;',mat2str(c(i).grd(1,2).b));
            j=j+1;
            string_sw{j,1} = sprintf('guards(2,1).b = %s;',mat2str(c(i).grd(2,1).b));
            j=j+1;
            string_sw{j,1} = sprintf('guards(1,2).A = %s;',mat2str(c(i).grd(1,2).A));
            j=j+1;
            string_sw{j,1} = sprintf('guards(2,1).A = %s;',mat2str(c(i).grd(2,1).A));
            j=j+1;
            if projection_mode == 1
                string_sw{j,1} = sprintf('guards(1,2).proj = %s;',mat2str(c(i).grd(1,2).proj));
                j=j+1;
                string_sw{j,1} = sprintf('guards(2,1).proj = %s;',mat2str(c(i).grd(2,1).proj));
                j=j+1;
            end
            string_sw{j,1} = sprintf('grd{%d}=guards;',i);
            j=j+1;    
        end
              
end

string_sat{1,1} = '';
j=1;
for i = switch_count+1:switch_count+saturation_count %length(c)-1
    %for j=6*(i-1)+1:6*i
        %j = 22*(i-switch_count-1)+1;
        string_sat{j,1} = 'adj = cell(0);';
        j=j+1;
        string_sat{j,1} = sprintf('adj{1}=[%d];',c(i).adj{1});
        j=j+1;
        string_sat{j,1} = sprintf('adj{2}=[%d %d];',c(i).adj{2});
        j=j+1;
        string_sat{j,1} = sprintf('adj{3}=[%d];',c(i).adj{3});
        j=j+1;
        string_sat{j,1} = sprintf('clg{%d}=adj;',i);
        j=j+1;
        string_sat{j,1} = 'guards = [];';
        j=j+1;
        string_sat{j,1} = sprintf('guards(1,2).A(1,:) = %s;',mat2str(c(i).grd(1,2).A(1,:)));
        j=j+1;
        string_sat{j,1} = sprintf('guards(1,2).A(2,:) = %s;',mat2str(c(i).grd(1,2).A(2,:)));
        j=j+1;
        string_sat{j,1} = sprintf('guards(1,2).b(1,:) = %s;',mat2str(c(i).grd(1,2).b(1,:)));
        j=j+1;
        string_sat{j,1} = sprintf('guards(1,2).b(2,:) = %s;',mat2str(c(i).grd(1,2).b(2,:)));
        j=j+1;
        string_sat{j,1} = sprintf('guards(2,1).A = %s;',mat2str(c(i).grd(2,1).A));
        j=j+1;
        string_sat{j,1} = sprintf('guards(2,1).b = %s;',mat2str(c(i).grd(2,1).b));
        j=j+1;
        if projection_mode == 1
            string_sat{j,1} = sprintf('guards(1,2).proj = %s;',mat2str(c(i).grd(1,2).proj));
            j=j+1;
            string_sat{j,1} = sprintf('guards(2,1).proj = %s;',mat2str(c(i).grd(2,1).proj));
            j=j+1;
        end
        string_sat{j,1} = sprintf('guards(1,3).A = %s;',mat2str(c(i).grd(1,3).A));
        j=j+1;
        string_sat{j,1} = sprintf('guards(1,3).b = %s;',mat2str(c(i).grd(1,3).b));
        j=j+1;
        string_sat{j,1} = sprintf('guards(3,1).A = %s;',mat2str(c(i).grd(3,1).A));
        j=j+1;
        string_sat{j,1} = sprintf('guards(3,1).b = %s;',mat2str(c(i).grd(3,1).b));
        j=j+1;
        if projection_mode == 1
            string_sat{j,1} = sprintf('guards(1,3).proj = %s;',mat2str(c(i).grd(1,3).proj));
            j=j+1;
            string_sat{j,1} = sprintf('guards(3,1).proj = %s;',mat2str(c(i).grd(3,1).proj));
            j=j+1;
        end
        string_sat{j,1} = sprintf('guards(2,3).A = %s;',mat2str(c(i).grd(2,3).A));
        j=j+1;
        string_sat{j,1} = sprintf('guards(2,3).b = %s;',mat2str(c(i).grd(2,3).b));
        j=j+1;
        string_sat{j,1} = sprintf('guards(3,2).A(1,:) = %s;',mat2str(c(i).grd(3,2).A(1,:)));
        j=j+1;
        string_sat{j,1} = sprintf('guards(3,2).A(2,:) = %s;',mat2str(c(i).grd(3,2).A(2,:)));
        j=j+1;
        string_sat{j,1} = sprintf('guards(3,2).b(1,:) = %s;',mat2str(c(i).grd(3,2).b(1,:)));
        j=j+1;
        string_sat{j,1} = sprintf('guards(3,2).b(2,:) = %s;',mat2str(c(i).grd(3,2).b(2,:)));
        j=j+1;
        if projection_mode == 1
            string_sat{j,1} = sprintf('guards(2,3).proj = %s;',mat2str(c(i).grd(2,3).proj));
            j=j+1;
            string_sat{j,1} = sprintf('guards(3,2).proj = %s;',mat2str(c(i).grd(3,2).proj));
            j=j+1;
        end
        string_sat{j,1} = sprintf('grd{%d} = guards;',i);
        j=j+1;
end
%%

strmodel{1,1} = sprintf('model = ''%s'';',New_Modelname);
strmodel{2,1} = 'warning off;';

strset{1,1} = 'simopt = simget(model);';
strset{2,1} = 'simopt = simset(simopt,''SaveFormat'',''Structure'');';
strset{3,1} = '[T, XT, YTstruct] = sim(model,[0 simT],simopt,[TU U]);';
strset{4,1} = 'YT = [];';
strset{5,1} = 'LT = [];';

strrun{1,1} = '';
str_iter = 1;
strrun{str_iter,1} = sprintf('for i = 1:%d',endofoutports);
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t Temp = YTstruct.signals(i).values;');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t YT = [YT, Temp];');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('end');
str_iter = str_iter+1;
strrun{str_iter,1} = 'YT = double(YT);';
str_iter = str_iter+1;
strrun{str_iter,1} = 'LT_switch = [];';
str_iter = str_iter+1;
strrun{str_iter,1} = 'LT_bool = [];';
str_iter = str_iter+1;
strrun{str_iter,1} = 'LT_float = [];';
str_iter = str_iter+1;
% if boolswitch ~= 0
%     strrun{str_iter,1} = sprintf('LT_bool = YT(:,%d:%d);',guardsize+1,endofoutports);
%     str_iter = str_iter+1;
%     strrun{str_iter,1} = sprintf('LT_bool = LT_bool+1;');
%     str_iter = str_iter+1;
% end
if boolswitch ~= 0
    strrun{str_iter,1} = sprintf('LT_bool_index = %s;',mat2str(LT_bool));
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('LT_bool = YT(:,LT_bool_index);');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('LT_bool = LT_bool+1;');
    str_iter = str_iter+1;
end

if doubleswitch ~= 0
%strrun{str_iter,1} = sprintf('LT_float = YT(:,%d:%d);',doubleport_start_index,doubleport_end_index);
strrun{str_iter,1} = sprintf('LT_float_index = %s;',mat2str(LT_float));
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('LT_float = YT(:,LT_float_index);');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('switch_threshold_mat = %s;',mat2str(switch_threshold_mat));
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('switch_criteria_mat = %s;',mat2str(switch_criteria_mat));
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('szltf = size(LT_float);');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('for i = 1:szltf(2)');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t for j = 1:szltf(1)');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t if(switch_criteria_mat(i) == 1)');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t if(LT_float(j,i) >= switch_threshold_mat(i))');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t\t LT_float(j,i) = 2;');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t else');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t\t LT_float(j,i) = 1;');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t end');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t else');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t if(LT_float(j,i) > switch_threshold_mat(i))');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t\t LT_float(j,i) = 2;');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t else');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t\t LT_float(j,i) = 1;');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t\t end');
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('\t\t end');
str_iter = str_iter+1;
% strrun{str_iter,1}=sprintf('\t\t if(LT_float(j,i) >= switch_threshold_mat(i))');   
% str_iter=str_iter+1;
% strrun{str_iter,1}=sprintf('\t\t\t LT_float(j,i)=2;');
% str_iter=str_iter+1;
% strrun{str_iter,1}=sprintf('\t\t else');
% str_iter=str_iter+1;
% strrun{str_iter,1}=sprintf('\t\t\t LT_float(j,i)=1;');
% str_iter=str_iter+1;
% strrun{str_iter,1}=sprintf('\t\t end'); %end if
% str_iter=str_iter+1;
strrun{str_iter,1} = sprintf('\t end'); %for j
str_iter = str_iter+1;
strrun{str_iter,1} = sprintf('end'); % for i
str_iter = str_iter+1;
end
strrun{str_iter,1} = sprintf('LT_switch = [LT_float LT_bool];');
str_iter = str_iter+1;


strrun{str_iter,1} = 'LT_sat = [];';
str_iter = str_iter+1;

if saturation_count ~= 0
    strrun{str_iter,1} = sprintf('sat_low_mat =  %s;',mat2str(saturate_block_info.low_threshold));
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('sat_high_mat =  %s;',mat2str(saturate_block_info.high_threshold));
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('sat_outportlist = %s;',mat2str(saturate_block_info.outport_list));
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('LT_sat = YT(:,%d:%d);',sat_startport_index,sat_endport_index);
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('szltsb = size(LT_sat);');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('for i = 1:szltsb(2)');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t for j = 1:szltsb(1)');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t\t if(LT_sat(j,i) <= sat_low_mat(i))');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t\t\t LT_sat(j,i) = 1;');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t\t elseif(LT_sat(j,i)> sat_low_mat(i)) && (LT_sat(j,i)< sat_high_mat(i))');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t\t\t LT_sat(j,i) = 2;');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t\t elseif(LT_sat(j,i)> sat_high_mat(i))');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t\t\t LT_sat(j,i) = 3;');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t\t end');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('\t end');
    str_iter = str_iter+1;
    strrun{str_iter,1} = sprintf('end');
    str_iter = str_iter+1;
end

strrun{str_iter,1} = sprintf('LT = [LT_switch LT_sat];');
str_iter = str_iter+1;
strrun{str_iter,1} = 'LT = double(LT);';
str_iter = str_iter+1;
if boolswitch ~= 0
    strrun{str_iter,1} = sprintf('LT_remove = %s;',mat2str(LT_remove));
    str_iter = str_iter+1;
    %strrun{str_iter,1} = sprintf('YT(:,%d:%d) =  [];',guardsize+1,endofoutports);
    strrun{str_iter,1} = sprintf('YT(:,LT_remove) =  [];');
    str_iter = str_iter+1;
end
strrun{str_iter,1} = sprintf('end');
str_iter = str_iter+1;
filename = sprintf('%s.m',bb_filename);

fileid = fopen(filename,'w');
    if(fileid ~= -1)
        fprintf(fileid,'%s\n',str{1,1});
        
        for i = 1:length(strinit)
            fprintf(fileid,'%s\n',strinit{i,1});
        end
        
        for i = 1:length(string_sw)
            fprintf(fileid,'%s\n',string_sw{i,1});
        end
        
        for i = 1:length(string_sat)
            fprintf(fileid,'%s\n',string_sat{i,1});
        end
            
        for i = 1:length(strmodel)
            fprintf(fileid,'%s\n',strmodel{i,1});
        end
        
        for i = 1:length(strset)
            fprintf(fileid,'%s\n',strset{i,1});
        end
        
        for i = 1:length(strrun)
            fprintf(fileid,'%s\n',strrun{i,1});
        end 
        
        fclose(fileid);
    else
        error('Unable to create blackbox file\n');
    end
    
bbox_filename = bb_filename;
end
   
