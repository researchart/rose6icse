% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = squeeze(X)
% squeeze (overloaded)

% Author Johan L�fberg
% $Id: squeeze.m,v 1.2 2006-07-26 09:09:07 joloef Exp $


dummy = reshape(ones(prod(X.dim),1),X.dim);
dummy = squeeze(dummy);
X.dim = size(dummy);
X = clean(X);
