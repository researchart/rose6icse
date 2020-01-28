% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function blockDepths = getBlockDepths(ancestorsList)
%getBlockDepths getDepth of blocks in the model.

try
    sizeOfList = size(ancestorsList);
    numOfBlocks = sizeOfList(1);
    blockDepths = zeros(numOfBlocks, 1);
    
    for i = 1:numOfBlocks
        ancestors = setdiff(ancestorsList{i}, -1);
        blockDepths(i) = numel(ancestors);
    end
catch
    error('ERROR: getBlockDepths failed !');
end

end

