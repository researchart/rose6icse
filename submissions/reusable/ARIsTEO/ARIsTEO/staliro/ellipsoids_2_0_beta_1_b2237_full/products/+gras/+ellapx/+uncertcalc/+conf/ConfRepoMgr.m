% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ConfRepoMgr<modgen.configuration.ConfRepoManagerUpd&...
        gras.ellapx.uncertcalc.conf.IConfRepoMgr
    methods
        function self=ConfRepoMgr(varargin)
            self=self@modgen.configuration.ConfRepoManagerUpd(varargin{:});
            confPatchRepo=gras.ellapx.uncertcalc.conf.ConfPatchRepo();
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end
