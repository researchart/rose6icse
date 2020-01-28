% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function simpleMethod(self)
[methodName className]=modgen.common.getcallernameext(1);
self.setCallerInfo(methodName,className);