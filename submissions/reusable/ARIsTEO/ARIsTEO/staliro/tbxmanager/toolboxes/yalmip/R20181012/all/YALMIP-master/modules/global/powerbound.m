% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function bound = powerbound(lb,ub,powers)
vars  = find(powers);
bound = [1 1];
for k = 1:length(vars)
    bound = intvmul(bound,intvpower([lb(vars(k)) ub(vars(k))],powers(vars(k))));
end