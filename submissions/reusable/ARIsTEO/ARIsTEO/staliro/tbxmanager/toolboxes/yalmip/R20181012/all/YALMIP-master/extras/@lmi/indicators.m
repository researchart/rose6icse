% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function s = indicators(F)

F = flatten(F);
try
    s = F.clauses{1}.extra.indicators;
catch
    s = [];
end