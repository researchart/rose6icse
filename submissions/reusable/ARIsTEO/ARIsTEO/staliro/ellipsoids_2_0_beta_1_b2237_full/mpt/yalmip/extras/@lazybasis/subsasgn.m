% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = subsasgn(X,I,Y)
%SUBASGN (overloaded)

% Author Johan L�fberg 
% $Id: subsasgn.m,v 1.1 2005-10-12 16:05:54 joloef Exp $   

if isa(X,'lazybasis');
    X = double(X);
end
if isa(Y,'lazybasis');
    Y = double(Y);
end
y = subsasgn(X,I,Y);
