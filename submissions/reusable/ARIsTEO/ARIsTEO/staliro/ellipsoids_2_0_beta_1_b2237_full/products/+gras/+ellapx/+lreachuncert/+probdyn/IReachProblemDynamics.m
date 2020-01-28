% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef IReachProblemDynamics<...
        gras.ellapx.lreachplain.probdyn.IReachProblemDynamics
    methods (Abstract)
        CqtDynamics=getCqtDynamics(self)
        CQCTransDynamics=getCQCTransDynamics(self)
    end
end