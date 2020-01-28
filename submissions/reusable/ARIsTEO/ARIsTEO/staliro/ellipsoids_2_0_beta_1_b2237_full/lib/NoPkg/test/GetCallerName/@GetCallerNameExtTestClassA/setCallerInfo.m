% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function obj=setCallerInfo(obj,methodName,className)
obj.className=className;
obj.methodName=methodName;