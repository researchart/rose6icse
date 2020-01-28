% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef LReachContProblemDef<gras.ellapx.lreachuncert.probdef.AReachContProblemDef
    methods
        function self=LReachContProblemDef(aCMat,bCMat,pCMat,pCVec,...
                cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
            %
            self=self@gras.ellapx.lreachuncert.probdef.AReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,...
                tLims);
        end
    end
end