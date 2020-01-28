% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function S = spy(X)
%SPY (overloaded)

F = flatten(X);
if length(X)>1
    S = [];
    for i = 1:length(X)
        S = blkdiag(S,spy(X.clauses{1}.data));
    end    
    if nargout == 0
        spy(S);
    end
else
    X = spy(sdpvar(X));
    if nargout==0
        spy(X);
    else
        S = X;
    end
end