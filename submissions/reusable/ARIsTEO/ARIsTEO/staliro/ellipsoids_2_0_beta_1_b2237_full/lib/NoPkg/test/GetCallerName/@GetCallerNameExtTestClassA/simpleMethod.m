% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function obj=simpleMethod(obj)
[methodName className]=modgen.common.getcallernameext(1);
obj=setCallerInfo(obj,methodName,className);