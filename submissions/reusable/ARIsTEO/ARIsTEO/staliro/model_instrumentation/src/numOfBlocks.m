% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function num = numOfBlocks(info)

if isfield(info, 'numOfBlocks')
    num = info.numOfBlocks;
else
    num = length(info.connMatrix);
end

end

