% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isPositive=iscol(inpArray)
isPositive=size(inpArray,1)==numel(inpArray)&&size(inpArray,2)==1;