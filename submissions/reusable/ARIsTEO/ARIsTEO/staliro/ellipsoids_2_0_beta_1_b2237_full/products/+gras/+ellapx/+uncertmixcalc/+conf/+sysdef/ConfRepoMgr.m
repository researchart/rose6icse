% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ConfRepoMgr<modgen.configuration.ConfRepoManagerUpd&...
        gras.ellapx.uncertmixcalc.conf.sysdef.AConfRepoMgr
    methods
        function self=ConfRepoMgr(varargin)
            import gras.ellapx.uncertmixcalc.conf.sysdef.AConfRepoMgr;
            import gras.ellapx.uncertmixcalc.conf.sysdef.ConfPatchRepo;
            confPatchRepo=ConfPatchRepo();            
            self=self@modgen.configuration.ConfRepoManagerUpd(varargin{:},...
                'getStorageHook',@AConfRepoMgr.getStorageHook,...
                'putStorageHook',@AConfRepoMgr.putStorageHook,...
                'confPatchRepo',confPatchRepo);
        end
    end
end
