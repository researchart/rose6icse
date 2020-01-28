% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef AdpConfRepoMgr<modgen.configuration.AdaptiveConfRepoManager
    %CONFIGURATIONREADERTEST Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function self=AdpConfRepoMgr(varargin)
            self=self@modgen.configuration.AdaptiveConfRepoManager(varargin{:});
        end
    end
end
