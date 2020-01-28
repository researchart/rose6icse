% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isLeaf = isBlockLeaf(block, connMatrix)

if isempty(find(connMatrix(block, :), 1))
    isLeaf = 1;
else
    isLeaf = 0;
end
end
