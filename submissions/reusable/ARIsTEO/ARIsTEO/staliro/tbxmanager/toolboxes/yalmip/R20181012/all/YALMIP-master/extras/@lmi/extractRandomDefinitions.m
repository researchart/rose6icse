% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function S = extractRandomDefinitions(F)
F = flatten(F);
S = {};
for i = 1:length(F)
    S{i}.variables = F.clauses{i}.data;
    S{i}.distribution =  struct(F.clauses{1}.data).extra.distribution;
end
