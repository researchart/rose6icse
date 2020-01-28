% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ConstMatrixFunction<gras.mat.AConstMatrixFunction
    methods
        function self=ConstMatrixFunction(cMat)
            self=self@gras.mat.AConstMatrixFunction(cMat);
            self.nDims = 2;
        end
    end
end