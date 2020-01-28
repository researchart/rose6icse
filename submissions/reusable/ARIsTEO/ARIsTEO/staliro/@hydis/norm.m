% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Norm overloaded for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function out = norm(inp)
if length(inp)>1
    error('hydis: norm is defined only for hydis values')
else
    out = norm([inp.ds inp.dl]);
end
