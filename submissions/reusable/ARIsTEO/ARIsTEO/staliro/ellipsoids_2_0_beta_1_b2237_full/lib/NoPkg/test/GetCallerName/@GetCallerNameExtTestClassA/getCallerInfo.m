% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [methodName className]=getCallerInfo(obj)
methodName=obj.methodName;
className=obj.className;