% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Isvector function overloaded for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function out = isvector(inp)
s_in = size(inp);
out = length(s_in)==2 & ((s_in(1)==1 & s_in(2)>0) | (s_in(1)>0 & s_in(2)==1));
end
