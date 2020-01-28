% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function obj=GetCallerExtTestClassA(varargin)

obj=struct;
[obj.methodName obj.className]=modgen.common.getcallernameext(1);
obj=class(obj,'GetCallerNameExtTestClassA');