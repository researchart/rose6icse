% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isPositive=isvec(inpArray)
isPositive=length(inpArray)==numel(inpArray)&&ndims(inpArray)<=2;