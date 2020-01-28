% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isPositive=iscellofstrvec(inpArray)
isPositive=iscellstr(inpArray)&&...
    all(reshape(cellfun(@modgen.common.isrow,inpArray),[],1));