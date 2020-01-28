% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  out = isequal(X,Y)
%ISEQUAL (overloaded)

% Author Johan L�fberg 
% $Id: isequal.m,v 1.1 2006-08-10 18:00:20 joloef Exp $   

if (isa(X,'sdpvar') & isa(Y,'sdpvar'))
    out = isequal(struct(X),struct(Y));
else
	out = 0;
end
	