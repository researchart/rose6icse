% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Size overloaded for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function [m,n] = size(inp,dim)
if nargout==2
    [m,n] = size(inp.ds);
elseif nargout==1 || nargout==0
    if nargin==1
        m = size(inp.ds);
    else
        m = size(inp.ds,dim);
    end
else
    error('hydis: size: Input not supported')    
end
