% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef AdpConfRepoMgrNegative<modgen.configuration.AdaptiveConfRepoManager
    methods
        function self=AdpConfRepoMgrNegative(varargin)
            confPatchRepo=...
                modgen.configuration.test.StructChangeTrackerNegative();
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end
