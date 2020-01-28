% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% script2BBox creates a new S-TaLiRo Black Box script that emulates the
% internal decisions of the MATLAB embedded code. 
% For more information about S-TaLiRo Black Box run:
% >> help staliro_blackbox
%
function [ bb_filename ] = script2BBox( matlabblockname,modelName,A_Array,bArray,DNFs,outPortNum,numHAs )
    global outputs;
    bb_filename = strcat('BlackBox_',matlabblockname);
    bbm=strcat(bb_filename,'.m');
    fid = fopen( bbm, 'wt' );
    bb_filename = strcat('BlackBox_',matlabblockname);
    fprintf(fid,'function [T, XT, YT, LT, CLG, Guards] = %s(X0,simT,TU,U)',bb_filename);
    fprintf(fid,'\nLT=[]; \n');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    for i=1:length(bArray)
        p(i).b=bArray(i);
        p(i).A=zeros(1,length(outputs)+outPortNum);
        if A_Array(i)>0
            p(i).A(A_Array(i)+outPortNum)=1;
        elseif A_Array(i)<0
            p(i).A(-A_Array(i)+outPortNum)=-1;
        end
    end
    for i=1:length(bArray)
        fprintf(fid,'p%d_A = %s;\n',i,mat2str(p(i).A));
        fprintf(fid,'p%d_b = %s;\n',i,mat2str(p(i).b));
        fprintf(fid,'\n');
    end
    if  numHAs==1
        for i=1:length(DNFs{1})
            fprintf(fid,'CLG{%d} = ',i);
            adj=[];
            for j=1:length(DNFs{1})
                if i~=j
                    adj=[adj,j];
                end
            end
            fprintf(fid,'%s;\n',mat2str(adj));
        end
        fprintf(fid,'\n');
        fprintf(fid,'\nGuards = [];\n');
        for i=1:length(DNFs{1})
            [token, remain]= strtok(DNFs{1}{i});
            to_loc_A='';
            to_loc_b='';
            while(isempty(token)~=1)
                if strcmp(token,'(')
                    to_loc_A=strcat(to_loc_A,'[');
                    to_loc_b=strcat(to_loc_b,'[');
                elseif strcmp(token,')')
                    to_loc_A=strcat(to_loc_A,']');
                    to_loc_b=strcat(to_loc_b,']');
                elseif strcmp(token,'!')
                    to_loc_A=strcat(to_loc_A,'-');
                    to_loc_b=strcat(to_loc_b,'-');
                elseif strcmp(token,'&')
                    to_loc_A=strcat(to_loc_A,';');
                    to_loc_b=strcat(to_loc_b,';');
                elseif strcmp(token,'|')
                    to_loc_A=strcat(to_loc_A,',');
                    to_loc_b=strcat(to_loc_b,',');
                elseif strncmp(token,'p',1)
                    num = str2num(token(2:end));
                    if num<=length(bArray)
                        to_loc_A=strcat(to_loc_A,token,'_A');
                        to_loc_b=strcat(to_loc_b,token,'_b');
                    else
                        error('predicate number does not correspond to any output');
                    end
                end
                [token, remain]= strtok(remain);
            end
            for j=1:length(DNFs{1})
                if i~=j
                    fprintf(fid,'Guards(%d,%d).A = {%s};\n',j,i,to_loc_A);
                    fprintf(fid,'Guards(%d,%d).b = {%s};\n',j,i,to_loc_b);
                end
            end
        end
    else
        fprintf(fid,'\n clg=cell(1,%d); \n grd=cell(1,%d);\n',numHAs,numHAs);
        for i=1:numHAs
            fprintf(fid,'\n adj = cell(0);\n \n');
            for j=1:length(DNFs{i})
                fprintf(fid,'adj{%d} = ',j);
                adj=[];
                for k=1:length(DNFs{i})
                    if k~=j
                        adj=[adj,k];
                    end
                end
                fprintf(fid,'%s;\n',mat2str(adj));
            end
            fprintf(fid,'\n clg{%d}=adj;\n',i);
            fprintf(fid,'\n guards = [];\n');
            for j=1:length(DNFs{i})
                [token, remain]= strtok(DNFs{i}{j});
                to_loc_A='';
                to_loc_b='';
                while(isempty(token)~=1)
                    if strcmp(token,'(')
                        to_loc_A=strcat(to_loc_A,'[');
                        to_loc_b=strcat(to_loc_b,'[');
                    elseif strcmp(token,')')
                        to_loc_A=strcat(to_loc_A,']');
                        to_loc_b=strcat(to_loc_b,']');
                    elseif strcmp(token,'!')
                        to_loc_A=strcat(to_loc_A,'-');
                        to_loc_b=strcat(to_loc_b,'-');
                    elseif strcmp(token,'&')
                        to_loc_A=strcat(to_loc_A,';');
                        to_loc_b=strcat(to_loc_b,';');
                    elseif strcmp(token,'|')
                        to_loc_A=strcat(to_loc_A,',');
                        to_loc_b=strcat(to_loc_b,',');
                    elseif strncmp(token,'p',1)
                        num = str2num(token(2:end));
                        if num<=length(bArray)
                            to_loc_A=strcat(to_loc_A,token,'_A');
                            to_loc_b=strcat(to_loc_b,token,'_b');
                        else
                            error('predicate number does not correspond to any output');
                        end
                    end
                    [token, remain]= strtok(remain);
                end
                for k=1:length(DNFs{i})
                    if k~=j
                        fprintf(fid,'guards(%d,%d).A = {%s};\n',k,j,to_loc_A);
                        fprintf(fid,'guards(%d,%d).b = {%s};\n',k,j,to_loc_b);
                    end
                end
            end
            fprintf(fid,'\n grd{%d}=guards;\n',i);
        end
    end
    fprintf(fid,'\n\n model = ''%s'' ; \n',modelName);
    fprintf(fid,'\n warning off\n');
    fprintf(fid,'\n simopt = simget(model);\n');
    fprintf(fid,'\n simopt = simset(simopt,''SaveFormat'',''Array'');\n') ;
    fprintf(fid,'\n [T, XT, YT] = sim(model,[0 simT],simopt,[TU U]);\n');
    if numHAs==1
        fprintf(fid,'\n LT = YT(:,[%d]);\n',length(outputs)+outPortNum+numHAs);
        fprintf(fid,'\n YT(:,[%d]) = [];\n',length(outputs)+outPortNum+numHAs);
    else
        locs=[];
        for i=1:numHAs
            locs=[locs,length(outputs)+outPortNum+i];
        end
        fprintf(fid,'\n LT = YT(:,%s);\n',mat2str(locs));
        fprintf(fid,'\n YT(:,%s) = [];\n',mat2str(locs));
    end
    fprintf(fid,'\nend \n');
    fclose(fid);
end

