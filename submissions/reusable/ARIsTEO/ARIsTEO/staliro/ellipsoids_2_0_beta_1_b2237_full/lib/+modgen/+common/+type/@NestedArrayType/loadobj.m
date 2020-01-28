% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function obj=loadobj(obj)
%update legacy structure
obj.typeInfo=modgen.common.type.updatetypeinfostruct(obj.typeInfo);
end
