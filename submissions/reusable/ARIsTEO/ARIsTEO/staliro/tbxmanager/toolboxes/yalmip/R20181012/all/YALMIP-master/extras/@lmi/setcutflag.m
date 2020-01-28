% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = setcutflag(X,flag)
%setcutlag Internal : defines a SET object as a CUT

if nargin == 1
    flag = 1;
end
X = flatten(X);
for i = 1:length(X.clauses)
    X.clauses{i}.cut = flag;
end