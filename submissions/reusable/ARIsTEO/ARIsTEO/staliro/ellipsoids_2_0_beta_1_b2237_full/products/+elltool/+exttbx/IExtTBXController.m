% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef (Abstract) IExtTBXController  
    methods(Abstract,Static)
        fullSetup(self,arg)
        isOnPath(self)
        checkIfSetUp(self)
        checkIfOnPath(self)
        checkSettings(self)
    end
end