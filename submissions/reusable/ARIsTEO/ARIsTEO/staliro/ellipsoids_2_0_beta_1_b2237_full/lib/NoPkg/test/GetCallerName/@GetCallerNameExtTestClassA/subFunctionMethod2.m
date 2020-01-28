% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function obj=subFunctionMethod2(obj)
obj=subFunction(obj);
end

function obj=subFunction(obj)
[methodName className]=modgen.common.getcallernameext(1);
obj=setCallerInfo(obj,methodName,className);
end