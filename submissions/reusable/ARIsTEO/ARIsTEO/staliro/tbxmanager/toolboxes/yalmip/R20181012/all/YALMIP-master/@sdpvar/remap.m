% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = remap(X,old,new)

X = sdpvarremap(X,old,new);