% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function n=length(X)
%LENGTH (overloaded)

% Author Johan L�fberg 
% $Id: length.m,v 1.3 2006-07-26 20:17:58 joloef Exp $   

n = max(X.dim);
