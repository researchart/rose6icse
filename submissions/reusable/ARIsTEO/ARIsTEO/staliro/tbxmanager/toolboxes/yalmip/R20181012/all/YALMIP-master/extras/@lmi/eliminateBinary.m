% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = eliminateBinary(F,binaries)

F = flatten(F);
for i = 1:length(F.clauses)
    data = eliminateBinary(F.clauses{i}.data,binaries);
    F.clauses{i}.data = data;
end