% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [f,df] = fmincon_fungp(x,prob)

z = prob.Afun*x;
w = exp(z);
f = full(log(prob.bfun'*w));
df = full(((1/(sum(prob.bfun.*w)))*(prob.bfun.*w)'*prob.Afun));