% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function subFunctionMethod(self)
subFunction();

    function subFunction()
        [methodName className]=modgen.common.getcallernameext(1);
        self.setCallerInfo(methodName,className);
    end
end