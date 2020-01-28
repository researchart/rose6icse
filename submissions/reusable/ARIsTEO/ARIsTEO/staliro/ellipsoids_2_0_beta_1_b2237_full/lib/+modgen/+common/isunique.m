% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [isPositive,outVec]=isunique(inpVec)
outVec=unique(inpVec);
isPositive=length(inpVec)==length(outVec);
