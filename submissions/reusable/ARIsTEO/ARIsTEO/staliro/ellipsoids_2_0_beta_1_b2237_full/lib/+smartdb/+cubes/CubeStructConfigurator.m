% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef CubeStructConfigurator
    methods (Static)
        function isPositive=isOfStaticType(obj)
            isPositive=isa(obj,...
                'smartdb.relations.ATypifiedStaticRelation');
        end
        function isPositive=isOfAutoType(obj)
            isPositive=isa(obj,'smartdb.cubes.TypifiedStruct')||...
                isa(obj,'smartdb.relations.DynTypifiedRelation');
        end
    end
end
