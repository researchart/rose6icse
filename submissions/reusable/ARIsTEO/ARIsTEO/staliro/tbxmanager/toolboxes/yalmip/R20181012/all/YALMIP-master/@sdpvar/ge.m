% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = ge(X,Y)
%GE (overloaded)

try
    y = constraint(X,'>=',Y);
catch
    error(lasterr)
end
