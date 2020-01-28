% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function X = setcutflag(X)
%setcutlag Intenal : defines a SET object as a CUT
%
% Author Johan Löfberg
% $Id: setcutflag.m,v 1.3 2005-02-10 12:26:38 johanl Exp $

X.clauses{1}.cut = 1;