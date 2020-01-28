% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef IEllApxBuilder<handle
    methods (Abstract)
        ellTubeRel=getEllTubes(self)
        calcPrecision=getCalcPrecision(self)
    end
end
