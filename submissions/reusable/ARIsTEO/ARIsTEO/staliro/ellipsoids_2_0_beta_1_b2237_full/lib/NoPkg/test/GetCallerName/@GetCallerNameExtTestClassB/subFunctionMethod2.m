% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function subFunctionMethod2(self)
subFunction(self);
end

function subFunction(self)
[methodName className]=modgen.common.getcallernameext(1);
self.setCallerInfo(methodName,className);
end