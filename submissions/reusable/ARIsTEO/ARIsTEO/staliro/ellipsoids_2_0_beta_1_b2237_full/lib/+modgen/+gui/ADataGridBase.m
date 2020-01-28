% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ADataGridBase<handle
    methods (Abstract)
        putData(self,colNameList,dataObj,varargin)
    end
    methods
        function self=ADataGridBase(varargin)
            import modgen.common.throwerror;
            if ~isempty(varargin)
                throwerror('wrongInput','no arguments is expected');
            end
        end
    end
end
