% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function anys = any(x)
%ANY (overloaded)

x_base = x.basis;
anys = full(sum(abs(x.basis),2)>0);
anys = reshape(anys,x.dim(1),x.dim(2));