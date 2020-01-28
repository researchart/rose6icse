% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef TypifiedByFieldCodeRel<smartdb.relations.ATypifiedByFieldCodeRel
    methods
        function self=TypifiedByFieldCodeRel(varargin)
            self=self@smartdb.relations.ATypifiedByFieldCodeRel(varargin{:});
        end
    end    
    methods (Access=protected)
        function fObj=getFieldDefObject(~)
            fObj=mlunitext.rels.F();
        end
    end
end