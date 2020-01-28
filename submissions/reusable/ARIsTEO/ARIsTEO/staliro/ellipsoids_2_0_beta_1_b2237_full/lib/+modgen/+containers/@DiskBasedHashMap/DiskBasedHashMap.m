% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef DiskBasedHashMap<modgen.containers.ondisk.HashMapMatXML
    methods
        function self=DiskBasedHashMap(varargin)
            self=self@modgen.containers.ondisk.HashMapMatXML(varargin{:});
        end
    end
end

