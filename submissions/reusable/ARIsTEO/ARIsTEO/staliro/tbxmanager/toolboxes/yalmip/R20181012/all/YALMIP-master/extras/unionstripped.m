% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function c = unionstripped(a,b)
%UNIONSTRIPPED  Internal function (version without checkings etc.)

c = uniquestripped([a(:)' b(:)']);


