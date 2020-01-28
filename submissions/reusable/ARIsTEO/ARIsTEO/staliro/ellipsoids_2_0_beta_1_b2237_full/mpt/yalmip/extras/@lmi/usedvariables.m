% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function used = lmi(F)

used = [];
for i = 1:length(F.clauses)
    Fi = F.clauses{i};
    used = unique([used;getvariables(Fi.data)']);
end
