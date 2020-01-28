% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef IReachContProblemDef<gras.ellapx.lreachplain.probdef.IReachContProblemDef
    methods (Abstract)
        cCMat=getCMatDef(self)
        qCVec=getqCVec(self)
        qCMat=getQCMat(self)
    end
end