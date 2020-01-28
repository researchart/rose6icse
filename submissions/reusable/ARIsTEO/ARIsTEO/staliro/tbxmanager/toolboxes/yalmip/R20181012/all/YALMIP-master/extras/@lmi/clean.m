% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = clean(F,tol)
%CLEAN Remove terms with small coefficients
%
% F = clean(F,tol) removes all terms with a coefficient smaller than tol

for j = 1:length(F.clauses)
    for i = 1:length(F.clauses{j})
        X = clean(F.clauses{j}{i}.data,tol);
        F.clauses{j}{i}.data = X;
    end
end