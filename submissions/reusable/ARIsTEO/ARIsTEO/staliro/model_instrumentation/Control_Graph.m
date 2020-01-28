% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ CLG,new_guardsize] = Control_Graph(switch_block_info,saturate_block_info,projection_mode)
% Generates the Hybrid Automata representaion for the switch and saturate
% blocks in the model.
% Inputs:
%	switch_block_info - information of the switch blocks obtained from
%	Switch_instrument. Refer to Switch_Instrument for details.
%	saturate_block_info - information of the saturate blocks obtained from
%   Saturate_Instrument. Refer to Saturate_Instrument for details. 
% Outputs:
%   CLG - Hybrid Automata representation for switch and saturate blocks 
%   with the following fields:
%       * adj - cell representing the adjacency matrix for each location of
%       the hybrid automata
%       * grd(i,j) - representing the condition for transition from state i
%       to state j
% For Ex: CLG for a switch block would be represented as follows :
%   CLG.adj{1}=2, CLG.adj{2}=1
%   CLG.grd(1,2).A = [0 0 -1 0 0],CLG.grd(2,1).A = [0 0 1 0 0],
%   CLG.grd(1,2).b = -1*threshold_val, CLG.grd(2,1).b = threshold_val
% switch_block_info=struct('bool_blocks',{},'double_blocks',{},'num_of_boolsw',[],'num_of_doublesw',[],'numport_index',[],'endport_index',[]);
    
    bool_switch = switch_block_info.num_of_boolsw;
    Switchconnhandlebool = switch_block_info.bool_blocks.conn_handle;
    Relsourcehandle = switch_block_info.bool_blocks.rel_conn_handle;
    predicate_table = switch_block_info.bool_blocks.predicate_table;
    DNF_string_12 = switch_block_info.bool_blocks.DNF_string_12;
    DNF_string_21 = switch_block_info.bool_blocks.DNF_string_21;
    %guardsize = switch_block_info.numport_index;
    
    switchdouble_info=switch_block_info.double_blocks;
    double_switch = switch_block_info.num_of_doublesw;
    if double_switch ~= 0
        double_out_endindex = switchdouble_info(double_switch).outportindex;
    end
    switch_count = bool_switch + double_switch;
    
    saturate_count= saturate_block_info.num_of_satblocks;
    sat_endport_index= saturate_block_info.endport_index;
    saturate_outportlist = saturate_block_info.outport_list;
    saturate_lowlimit = saturate_block_info.low_threshold;
    saturate_highlimit = saturate_block_info.high_threshold;
    
    %detremine the guard size based on saturate,double and bool switches
    if bool_switch == 0
        if double_switch == 0
            guardsize = sat_endport_index;
        else
            guardsize = double_out_endindex;
        end
    else
        guardsize = switch_block_info.numport_index;
    end
    
    %projection_mode=1;
    
    c={};
    Cntrlgraphindex=0;
    
    % create CLG for double switch first 
    for i_count=1:double_switch
        %if(Switchconnhandlebool(i_count,1) == 0)
            Cntrlgraphindex=Cntrlgraphindex+1;
            c(Cntrlgraphindex).adj{1}=[2];
            c(Cntrlgraphindex).adj{2}=[1];
 %built in double switch blocks check for '>' or '>=' guard can be directly written with '-1'.           
            c(Cntrlgraphindex).grd(1,2).b=0;  
            c(Cntrlgraphindex).grd(1,2).b= -1*switchdouble_info(i_count,1).threshold;
            c(Cntrlgraphindex).grd(2,1).b=c(Cntrlgraphindex).grd(1,2).b.*-1;
            if projection_mode == 0
                c(Cntrlgraphindex).grd(1,2).A=zeros(1,guardsize);
                c(Cntrlgraphindex).grd(1,2).A(1,switchdouble_info(i_count,1).outportindex)=-1; 
                c(Cntrlgraphindex).grd(2,1).A= c(Cntrlgraphindex).grd(1,2).A.*-1;
            else
            % for projection
                c(Cntrlgraphindex).grd(1,2).A = [];
                c(Cntrlgraphindex).grd(1,2).proj = [];
                i_proj=1;

                c(Cntrlgraphindex).grd(1,2).A(1,i_proj) = -1;
                c(Cntrlgraphindex).grd(1,2).proj(1,i_proj) = switchdouble_info(i_count,1).outportindex;

                c(Cntrlgraphindex).grd(2,1).A = c(Cntrlgraphindex).grd(1,2).A.*-1;
                c(Cntrlgraphindex).grd(2,1).proj = c(Cntrlgraphindex).grd(1,2).proj;
            end
            
        %end
    end
    
    %create CLG for bool switch
    
    for i_count=1:bool_switch
        Cntrlgraphindex=Cntrlgraphindex+1;
        c(Cntrlgraphindex).adj{1}=[2];
        c(Cntrlgraphindex).adj{2}=[1];
        c(Cntrlgraphindex).grd(1,2).A = [];
        c(Cntrlgraphindex).grd(1,2).b=0;
        [c(Cntrlgraphindex).grd(1,2).A,c(Cntrlgraphindex).grd(1,2).b,c(Cntrlgraphindex).grd(1,2).proj] = ...
        DNF_CLG(DNF_string_12{i_count},predicate_table{i_count},guardsize,projection_mode);
        [c(Cntrlgraphindex).grd(2,1).A,c(Cntrlgraphindex).grd(2,1).b, c(Cntrlgraphindex).grd(2,1).proj] = ...
        DNF_CLG(DNF_string_21{i_count},predicate_table{i_count},guardsize,projection_mode);  
    end
    
  %%% Control graph for saturate blocks  
    for i_count=1:saturate_count
        Cntrlgraphindex=Cntrlgraphindex+1;
        c(Cntrlgraphindex).adj{1}=[2];
        c(Cntrlgraphindex).adj{2}=[1,3];
        c(Cntrlgraphindex).adj{3}=[2];
        
        c(Cntrlgraphindex).grd(1,2).b=[0;0];
        c(Cntrlgraphindex).grd(1,3).b=0;
        c(Cntrlgraphindex).grd(2,1).b=0;
        c(Cntrlgraphindex).grd(2,3).b=0;
        c(Cntrlgraphindex).grd(3,1).b=0;
        c(Cntrlgraphindex).grd(3,2).b=[0;0];
        
        c(Cntrlgraphindex).grd(1,2).b(1,1)= saturate_highlimit(i_count);
        c(Cntrlgraphindex).grd(1,2).b(2,1)= -1*saturate_lowlimit(i_count);
        c(Cntrlgraphindex).grd(1,3).b=-1 * saturate_highlimit(i_count);
        c(Cntrlgraphindex).grd(2,1).b=saturate_lowlimit(i_count);
        c(Cntrlgraphindex).grd(2,3).b=-1 * saturate_highlimit(i_count);
        c(Cntrlgraphindex).grd(3,1).b=saturate_lowlimit(i_count);
        c(Cntrlgraphindex).grd(3,2).b(1,1)= saturate_highlimit(i_count);
        c(Cntrlgraphindex).grd(3,2).b(2,1)= -1*saturate_lowlimit(i_count);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        if projection_mode == 0
            c(Cntrlgraphindex).grd(1,2).A=zeros(2,guardsize);
            c(Cntrlgraphindex).grd(1,3).A=zeros(1,guardsize);
            c(Cntrlgraphindex).grd(2,1).A=zeros(1,guardsize);
            c(Cntrlgraphindex).grd(2,3).A=zeros(1,guardsize);
            c(Cntrlgraphindex).grd(3,1).A=zeros(1,guardsize);
            c(Cntrlgraphindex).grd(3,2).A=zeros(2,guardsize);

            c(Cntrlgraphindex).grd(1,2).A(1,saturate_outportlist(i_count))= 1;
            c(Cntrlgraphindex).grd(1,2).A(2,saturate_outportlist(i_count))= -1;
            c(Cntrlgraphindex).grd(1,3).A(1,saturate_outportlist(i_count))= -1;
            c(Cntrlgraphindex).grd(2,1).A(1,saturate_outportlist(i_count))= 1;
            c(Cntrlgraphindex).grd(2,3).A(1,saturate_outportlist(i_count))= -1;
            c(Cntrlgraphindex).grd(3,1).A(1,saturate_outportlist(i_count))= 1;
            c(Cntrlgraphindex).grd(3,2).A(1,saturate_outportlist(i_count))= 1;
            c(Cntrlgraphindex).grd(3,2).A(2,saturate_outportlist(i_count))= -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        else
            c(Cntrlgraphindex).grd(1,2).A=[];
            c(Cntrlgraphindex).grd(1,2).proj=[];

            c(Cntrlgraphindex).grd(1,3).A = [];
            c(Cntrlgraphindex).grd(1,3).proj = [];

            c(Cntrlgraphindex).grd(2,1).A = [];
            c(Cntrlgraphindex).grd(2,1).proj = [];
            c(Cntrlgraphindex).grd(2,3).A = [];
            c(Cntrlgraphindex).grd(2,3).proj = [];

            c(Cntrlgraphindex).grd(3,1).A = [];
            c(Cntrlgraphindex).grd(3,1).proj = [];
            c(Cntrlgraphindex).grd(3,2).A = [];
            c(Cntrlgraphindex).grd(3,2).proj = [];
            %%%%%%%%
            c(Cntrlgraphindex).grd(1,2).A(1,1)= 1;
            c(Cntrlgraphindex).grd(1,2).A(2,1)= -1;
            c(Cntrlgraphindex).grd(1,2).proj(1,1) = saturate_outportlist(i_count);
            c(Cntrlgraphindex).grd(1,3).A = -1;
            c(Cntrlgraphindex).grd(1,3).proj = saturate_outportlist(i_count);

            c(Cntrlgraphindex).grd(2,1).A(1,1)= 1;
            c(Cntrlgraphindex).grd(2,1).proj(1,1) = saturate_outportlist(i_count);
            c(Cntrlgraphindex).grd(2,3).A(1,1) = -1;
            c(Cntrlgraphindex).grd(2,3).proj(1,1) = saturate_outportlist(i_count);

            c(Cntrlgraphindex).grd(3,1).A(1,1)= 1;
            c(Cntrlgraphindex).grd(3,1).proj(1,1) = saturate_outportlist(i_count);
            c(Cntrlgraphindex).grd(3,2).A(1,1) = 1;
            c(Cntrlgraphindex).grd(3,2).A(2,1) = -1;
            c(Cntrlgraphindex).grd(3,2).proj(1,1) = saturate_outportlist(i_count);
        end
    end  
    CLG=c;
    new_guardsize = guardsize;
end

