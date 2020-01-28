% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ colorRGB, colorAsStr ] = getMappingColor_mr( core, sampleTimeId )
%getMappingColor Returns color to illustrate the core mapping
%colorRGB in RGB values, colorAsStr as string like 'red'

    if core == 1
        colorChar = 'r';
        colorAsStr = 'red';
    elseif core == 2
        colorChar = 'b';
        colorAsStr = 'blue';
    elseif core == 3
        colorChar = 'm';
        colorAsStr = 'magenta';
    elseif core == 4
        colorChar = 'c';
        colorAsStr = 'cyan';
    elseif core == 0
        colorChar = 'g';
        colorAsStr = 'green';
    else
        colorChar = 'k';
        colorAsStr = 'black';
    end
    colorRGB = rem(floor((strfind('kbgcrmyw', colorChar) - 1) * [0.25 0.5 1]), 2);
end

