% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% 'findIfElse' finds the independednt If-Then-Else blocks. It is used 
% internally by the function 'findNumberOfHAs'.

function [ line ] = findIfElse( textLines,line )
    szl=size(textLines);
    line=line+1;
    while line<=szl(1)
        [token, remain]= strtok(textLines{line});
        if(strncmp(token,'if',2))
            line=findIfElse(textLines,line);
        elseif(strncmp(token,'end',3))
            line=line+1;
            return;
        else
            line=line+1;
        end
    end
end

