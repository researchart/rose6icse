% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
%Sort hydis object cell array
%The function returns two rows, 1st row with the sorted values and the 2nd
%row with the indices of the original cell array.

function [sortedArray] = quickSortHydisCell(hydisArray)

if size(hydisArray,1) < 2
    for ii = 1:size(hydisArray,2)
        hydisArray{2,ii} = ii;
    end
end

sizeArray = size(hydisArray,2);
ind = cast(floor(sizeArray/2),'uint8');
j = 1;
k = 1;
left = cell(hydis);
right = cell(hydis);
if(sizeArray<2)
    sortedArray = hydisArray;
else
    piv(1,1) = hydisArray(1,ind);
    piv{2,1} = hydisArray{2,ind};
    for i=1:sizeArray
        if(i~=ind)
            if(lt(hydisArray{1,i},piv{1,1}))
                left{1,j} = hydisArray{1,i};
                left{2,j} = hydisArray{2,i};
                j = j+1;
            else
                right{1,k} = hydisArray{1,i};
                right{2,k} = hydisArray{2,i};
                k = k+1;
            end
        end
    end
    left = quickSortHydisCell(left);
    right = quickSortHydisCell(right);    
    if isempty(left{1})
        sortedArray = [piv right];
    elseif isempty(right{1})
        sortedArray = [left piv];
    else        
        sortedArray = [left piv right];
    end
end