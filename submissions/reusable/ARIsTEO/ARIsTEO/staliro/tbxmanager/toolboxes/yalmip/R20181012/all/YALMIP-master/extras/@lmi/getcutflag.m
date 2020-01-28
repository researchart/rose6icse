% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function c = getcutflag(X)

X = flatten(X);
c = [];
for i = 1:length(X.clauses)
    c = [c;X.clauses{i}.cut];
end