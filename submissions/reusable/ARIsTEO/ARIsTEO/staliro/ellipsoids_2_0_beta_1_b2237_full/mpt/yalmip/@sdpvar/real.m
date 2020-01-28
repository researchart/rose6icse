% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = real(X)
%REAL (overloaded)

% Author Johan L�fberg 
% $Id: real.m,v 1.5 2007-08-03 11:41:16 joloef Exp $   

X.basis = real(X.basis);
X = clean(X);
if isa(X,'sdpvar')
   X.conicinfo = [0 0];
end