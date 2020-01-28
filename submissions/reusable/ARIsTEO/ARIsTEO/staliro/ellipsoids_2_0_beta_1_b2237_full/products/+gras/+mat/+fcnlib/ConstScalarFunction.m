% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ConstScalarFunction<gras.mat.AConstMatrixFunction
    methods
        function self=ConstScalarFunction(cVec)
            modgen.common.type.simple.checkgen(cVec,'isscalar(x)');
            %
            self=self@gras.mat.AConstMatrixFunction(cVec);
            self.nDims = 1;
        end
    end
end