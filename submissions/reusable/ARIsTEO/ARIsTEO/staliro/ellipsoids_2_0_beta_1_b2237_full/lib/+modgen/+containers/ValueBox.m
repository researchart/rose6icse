% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ValueBox<handle
    properties
        val
    end
    %
    methods
        function setValue(self,val)
            self.val=val;
        end
        function val=getValue(self)
            val=self.val;
        end
    end
end
