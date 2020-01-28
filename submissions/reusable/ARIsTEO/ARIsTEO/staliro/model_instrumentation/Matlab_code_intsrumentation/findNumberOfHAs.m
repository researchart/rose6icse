% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% findNumberOfHAs finds the independent If-Then-Else blocks which  
% correspond to Hybrid Automatas. 
% 
% findNumberOfHAs( textLines ) needs one parameter 'textLines' which is the 
% MATLAB embedded code in the string format. 'textLines' string is parsed  
% by the function to extract the main If-Then-Else blocks. Each If-Then- 
% Else block corresponds to one independent Hybrid Automata.
% 
% Outputs are as follows:
% 'ifLines' is an integer array. The array contains the first lines of each 
% If-Then-Else blocks which are the lines that contain the 'if' keyword.
% 
% 'fcn_end' is an integer number where the MATLAB function block ends. 
% Namely, this is the last line of 'textLines' which contains the 'end'
% keyword.
% 

function [ ifLines,fcn_end ] = findNumberOfHAs( textLines )
    ifLines=[];
    line=1;
    sz=size(textLines);
    while line<=sz(1)
        [token, remain]= strtok(textLines{line});
        if(strncmp(token,'if',2))
            ifLines=[ifLines;line];
            line=findIfElse(textLines,line);
        elseif(strncmp(token,'end',3))
            fcn_end=line;
            return;
        else
            line=line+1;
        end
    end

end

