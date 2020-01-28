% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = eq(X,Y)
%EQ (overloaded)

if isa(X,'ndsdpvar')
    X = sdpvar(X);
elseif isa(X,'double')
    X = X(:);
end

if isa(Y,'ndsdpvar')
    Y = sdpvar(Y);
elseif isa(Y,'double')
    Y = Y(:);
end

try
    y = constraint(X,'==',Y);
catch
    error(lasterr)
end
