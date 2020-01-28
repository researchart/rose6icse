% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Maximum function overloaded for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function out = max(inp1,inp2)
if nargin==2 && length(inp1)==1 && length(inp2)==1
    if inp1<=inp2
        out = inp2;
    else
        out = inp1;
    end
else
    error('hydis: Only maximum between two hydis values is supported.') 
end
