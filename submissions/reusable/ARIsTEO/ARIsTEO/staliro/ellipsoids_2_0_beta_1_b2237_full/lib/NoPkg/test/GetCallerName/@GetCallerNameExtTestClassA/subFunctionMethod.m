% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function obj=subFunctionMethod(obj)
subFunction();

    function subFunction()
        [methodName className]=modgen.common.getcallernameext(1);
        obj=setCallerInfo(obj,methodName,className);
    end
end