% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ blockContainsDelay ] = checkIfBlockContainsDelay(info, blockIndex)
%checkIfBlockContainsDelay Check if block contains a delay.

blockContainsDelay = 0;
try
    if ~isempty(find(info.blockSpecialties{blockIndex} == 1, 1))
        blockContainsDelay = 1;
    end
catch
    error('ERROR: checkIfBlockContainsDelay failed !');
end
end

