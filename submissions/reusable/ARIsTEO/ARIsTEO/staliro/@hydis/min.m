% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Minimum function overloaded for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function [out idx] = min(inp1,inp2)
if nargin==1 && isvector(inp1)
    mm = length(inp1);
    out = hydis(0);
    out.ds = inp1.ds(1);
    out.dl = inp1.dl(1);
    idx = 1;
    for ii = 2:mm
        if hydis(inp1.dl(ii),inp1.ds(ii))<out
            out.ds = inp1.ds(ii);
            out.dl = inp1.dl(ii);
            idx = ii;
        end
    end
elseif nargin==2 && length(inp1)==1 && length(inp2)==1
    if inp1<=inp2
        out = inp1;
    else
        out = inp2;
    end
else
    error('hydis: Only minimum between two hydis values is supported or a vector of hydis values.') 
end
