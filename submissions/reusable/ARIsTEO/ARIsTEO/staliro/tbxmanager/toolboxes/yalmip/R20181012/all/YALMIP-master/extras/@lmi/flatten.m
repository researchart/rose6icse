% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = flatten(sys)

% Go from an internal format which is hierarchical and performs better
% when adding many constraint objects.
if length(sys.clauses)>0
    if isa(sys.clauses{1},'cell')
        sys.clauses = [sys.clauses{:}];
    end
end