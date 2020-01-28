% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  out = isequal(X,Y)
%ISEQUAL (overloaded)

if (isa(X,'ncvar') & isa(Y,'ncvar'))
    out = isequal(struct(X),struct(Y));
else
	out = false;
end
	