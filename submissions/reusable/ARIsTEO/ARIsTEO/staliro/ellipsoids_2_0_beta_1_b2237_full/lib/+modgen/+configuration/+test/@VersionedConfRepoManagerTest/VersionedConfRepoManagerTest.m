% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef VersionedConfRepoManagerTest<modgen.configuration.VersionedConfRepoManager&...
        modgen.configuration.test.StructChangeTrackerTest
    %CONFIGURATIONREADERTEST Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function self=VersionedConfRepoManagerTest(varargin)
            self=self@modgen.configuration.VersionedConfRepoManager(varargin{:});
        end
    end
end
