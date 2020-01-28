% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = vec(x)

x.dim = [prod(x.dim) 1];
