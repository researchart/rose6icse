% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = tag(F,text)
% TAG
%
% Sets the tag on a constraint.

% Author Johan L�fberg
% $Id: tag.m,v 1.1 2006-05-16 12:32:36 joloef Exp $

for i = 1:length(F.clauses)
    F.clauses{i}.handle = text;
end
