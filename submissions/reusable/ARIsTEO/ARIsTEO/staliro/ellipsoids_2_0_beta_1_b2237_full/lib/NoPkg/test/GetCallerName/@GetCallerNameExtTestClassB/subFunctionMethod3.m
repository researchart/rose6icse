% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function subFunctionMethod3(self)
subFunction(self);
end

function subFunction(self)
    subFunction2();

    function subFunction2()
        [methodName className]=modgen.common.getcallernameext(1);
        self.setCallerInfo(methodName,className);
    end
end