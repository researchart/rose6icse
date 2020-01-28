% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [E,F] = getEFfromSET(Z);

vars = getvariables(Z);
E = [];
for i = 1:length(vars)
    F{i} = [];
end

for j = 1:length(Z)    
    Zi = sdpvar(Z(j));
    E = blkdiag(E,getbasematrix(Zi,0));    
    for i = 1:length(vars)
        F{i} = blkdiag(F{i},-getbasematrix(Zi,vars(i)));
    end
end