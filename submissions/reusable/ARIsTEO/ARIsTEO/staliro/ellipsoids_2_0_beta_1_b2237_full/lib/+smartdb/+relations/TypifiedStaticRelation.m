% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef TypifiedStaticRelation<smartdb.relations.ATypifiedStaticRelation
    methods
        function self=TypifiedStaticRelation(varargin)
            self=self@smartdb.relations.ATypifiedStaticRelation(varargin{:});
        end
    end
    methods (Access=protected)
        function initialize(self,varargin)
              self.parseAndAssignFieldProps(varargin{:});
        end
    end    
end
