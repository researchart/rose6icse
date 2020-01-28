% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef IMatrixFunction<handle
    methods (Abstract)
        mSize=getMatrixSize(self)
        res=evaluate(self,timeVec)
        nDims=getDimensionality(self)
        nCols=getNCols(self)
        nRows=getNRows(self)
    end
end