% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ConfRepoMgrAdv<modgen.configuration.ConfRepoManager
    %CONFIGURATIONREADERTEST Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function self=ConfRepoMgrAdv(varargin)
            self=self@modgen.configuration.ConfRepoManager(varargin{:});
        end
    end
end
