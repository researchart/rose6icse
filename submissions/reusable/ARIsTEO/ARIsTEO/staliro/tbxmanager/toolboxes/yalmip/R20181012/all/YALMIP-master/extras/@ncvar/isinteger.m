% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isint=isinteger(X)
%ISINTEGER Check if (part of) a variable is integer

isint = any(ismember(getvariables(X),yalmip('intvariables')));
