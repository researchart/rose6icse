% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function setsos(X,h,ParametricVariables,Q,v)
%SETSOS Internal function

yalmip('setsos',X.extra.sosid,h,ParametricVariables,Q,v);
