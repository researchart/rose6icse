% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isPositive=iscelloffunc(inpArray)
isPositive=iscell(inpArray)&&...
    all(cellfun('isclass',inpArray,'function_handle'));