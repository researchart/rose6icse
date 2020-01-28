% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  [bool_blocklist_cell,bool_conn_matrix_cell] = process_bool(blockList,connHandleList,Switchconnhandlebool,connMatrix,info)
  
  bool_blocklist_cell = {};
  bool_conn_matrix_cell = {};
  global boolindexmat;
  global markedlist;

  boolindexmat=[];
  %markedlist=cell(length(blockList),1);
  markedlist=cell(info.numOfMainBlocks,1);
  %markedlist=zeros(length(blockList),1);
  switch_cell_size=size(Switchconnhandlebool); %since it is not vector
  bool_swcount= switch_cell_size(1,1);
  
  %bool_blocklist_cell=cell(swcount,1);
  %bool_conn_matrix_cell=cell(swcount,1);
  bool_count=0;
  for i=1:bool_swcount
        %if (switcharray{i,3}==2)
            bool_count = bool_count+1;
            for j=1:info.numOfMainBlocks %length(blockList)
                if(connHandleList(j)==Switchconnhandlebool(i,1))
                    boolsourceblock=j;%info.mainBlockIndices{j};
%                   bool_blocklist = [];
%                   bool_conn_matrix = [];
                    bool_blocklist_main= extractbool(blockList,connMatrix,boolsourceblock,info);
                    bool_blocklist_main=[boolsourceblock,bool_blocklist_main];
                    bool_blocklist = zeros(length(bool_blocklist_main),1);
                    bool_conn_matrix=extractboolconnmap(bool_blocklist_main,connMatrix);
                    for i_mainblk = 1:length(bool_blocklist_main)
                        bool_blocklist(i_mainblk) = info.mainBlockIndices {bool_blocklist_main(i_mainblk)};
                    end
                    bool_blocklist_cell{bool_count,1}= bool_blocklist;
                    bool_conn_matrix_cell{bool_count,1}=bool_conn_matrix;
                    boolindexmat=[]; %added to reset for next sw block.
                    markedlist=cell(info.numOfMainBlocks,1);
                    break;
                end   
            end
        %end
  end
end

function[bool_blocklist] = extractbool(blockList,connMatrix,boolsourceblock,info)

    global boolindexmat;
    global markedlist;   
    for ipos=1 : length(connMatrix)
        if (connMatrix(ipos,boolsourceblock)~=0)
            %if ~isempty(markedlist)
            if (isempty(markedlist{ipos}))% if markedlist(ipos)==0)
                markedlist{ipos}=1; % markedlist(ipos)=1;
                blockType = cellstr(get_param(blockList{info.mainBlockIndices{ipos}}, 'BlockType'));
       % if block type not relational/logic or constant then ignore those
       % blocks for recursion.
                if ~ (strcmpi(blockType,'RelationalOperator')|| strcmpi(blockType,'Constant')||strcmpi(blockType,'Logic'))
                    continue;
                end
                boolindexmat=[boolindexmat,ipos];
                if strcmpi(blockType,'RelationalOperator')|| strcmpi(blockType,'Constant')
                    %process here the 2 blocks connected to relational
                    %blocks
                    bool_blocklist=boolindexmat;
                    %return;
                else
                    bool_blocklist=extractbool(blockList,connMatrix,ipos,info);
                end
            end             
        end
    end 
    bool_blocklist=boolindexmat;
end

function [bool_conn_matrix]=extractboolconnmap(bool_blocklist,connMatrix)

%boolconnmat=zeros(boolsize);
%global connMatrix;
%global boolindexmat;
% global boolcellmap;
% bool_conn_matrix= cell (length(boolcellmap),1);
%     for i= 1:length (boolcellmap)
        
        boolconnmat=zeros(length (bool_blocklist));
        for j=1:length (bool_blocklist)
            for k=1:length (bool_blocklist)
                if (connMatrix(bool_blocklist(j),bool_blocklist(k))~=0)
                    boolconnmat(j,k)=1;   
                else
                    boolconnmat(j,k)=0;
                end
            end
        end
        bool_conn_matrix = boolconnmat;
    
end

    
        
    
