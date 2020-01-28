% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function classNameList=typeinfo2classname(STypeInfo)
%
if STypeInfo.depth>0
    classNameList=[repmat({'cell'},1,STypeInfo.depth),{STypeInfo.type}];
else
    classNameList={STypeInfo.type};
end