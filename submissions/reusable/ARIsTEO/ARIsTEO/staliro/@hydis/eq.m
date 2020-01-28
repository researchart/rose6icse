% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Equal overloaded for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function out = eq(inp1,inp2)
inp1 = hydis(inp1);
inp2 = hydis(inp2);
out = ((inp1.dl==inp2.dl) & (inp1.ds==inp2.ds));
end
