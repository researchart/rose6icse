% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = eq(X,Y)
%EQ (overloaded)

if isa(X,'blkvar')
    X = sdpvar(X);
end

if isa(Y,'blkvar')
    Y = sdpvar(Y);
end

try
    y = constraint(X,'==',Y);
catch
    error(lasterr)
end
