% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [children] = checkIfBlockIsAParent(blockHandle, parentsArr)
%checkIfBlockIsAParent Returns all children of block. children is empty if
%there is no child.

children = [];
for i = 1:length(parentsArr)
    if parentsArr(i) == blockHandle
        children = [children, i];
    end
end

end

