% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function classNameList=typeinfo2classname(STypeInfo)
%
STypeInfo=modgen.common.type.NestedArrayType.fromStruct(STypeInfo);
classNameList=STypeInfo.toClassName();