% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = value(X)
%double           Overloaded.

X = flatten(X);
nlmi = length(X.LMIid);

if (nlmi == 0) 
 sys = NaN;
end

if nlmi>1 
 error('Double not applicable on list of constraints')
end

sys = value(X.clauses{1}.data);
