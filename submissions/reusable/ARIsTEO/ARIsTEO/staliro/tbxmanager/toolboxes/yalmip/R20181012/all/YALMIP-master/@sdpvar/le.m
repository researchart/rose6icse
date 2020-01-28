% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = le(X,Y)
%LE (overloaded)

try
    y = constraint(X,'<=',Y);
catch
    error(lasterr)
end
