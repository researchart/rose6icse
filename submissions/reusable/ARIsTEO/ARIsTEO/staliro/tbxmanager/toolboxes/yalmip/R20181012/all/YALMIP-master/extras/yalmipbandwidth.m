% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function b = yalmipbandwidth(S)

if isa(S,'sdpvar')
    S = spy(S);
end
[i,j] = find(triu((S)));
b = max(abs(i-j));

