% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isPositive=ismstring(inpArray)
isPositive=isequal(inpArray,'')||(modgen.common.isrow(inpArray)&&ischar(inpArray));