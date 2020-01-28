% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [methodName callerName]=getcallernameext_subfunction2()
[methodName callerName]=subfunction();
end

function [methodName callerName]=subfunction()
[methodName callerName]=modgen.common.getcallernameext(1);
end