% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef MatrixTriuFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixTriuFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,@triu);
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
