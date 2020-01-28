% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
%Sort hydis object array

function [sortedArray] = quickSort(hydisArray)
sizeArray = size(hydisArray,2);
ind = cast(floor(sizeArray/2),'uint8');
j = 1;
k = 1;
left = hydis;
right = hydis;
if(sizeArray<2)
    sortedArray = hydisArray;
else
    piv = hydisArray(ind);
    for i=1:sizeArray
        if(i~=ind)
            if(lt(hydisArray(i),piv))
                left(j) = hydisArray(i);
                j = j+1;
            else
                right(k) = hydisArray(i);
                k = k+1;
            end
        end
    end
    left = quickSort(left);
    right = quickSort(right);
    sortedArray = [left piv right];
end