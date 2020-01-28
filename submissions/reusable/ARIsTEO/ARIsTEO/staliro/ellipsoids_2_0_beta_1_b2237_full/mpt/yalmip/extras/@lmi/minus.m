% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = minus(X,Y)
%MINUS (overloaded)

% Author Johan L�fberg
% $Id: minus.m,v 1.1 2004-12-07 08:46:53 johanl Exp $

if isempty(X)
    sys = set([]);
end

if isempty(Y)
    sys = X;
end

idX = getlmiid(X);
idY = getlmiid(Y);
YinX = find(~ismember(idX,idY));
% Get the correct subsref...
sys = subsref(X,struct('type','()','subs',{{YinX}}));
