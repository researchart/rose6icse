% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function ancestorsList = getAncestors(parentIndices)
%getAncestors Returns all the parents up to model root in a list.

try
    ancestorsList = cell(numel(parentIndices), 1);
    for i = 1:numel(parentIndices)
        ancestorsList{i} = parentIndices(i);
        lastAddedParent = parentIndices(i);
        while lastAddedParent > 1 % While not root
            lastAddedParent = parentIndices(lastAddedParent);
            ancestorsList{i} = [ancestorsList{i}, lastAddedParent];
        end
    end
catch
    error('ERROR: getAncestors failed!');
end
end

