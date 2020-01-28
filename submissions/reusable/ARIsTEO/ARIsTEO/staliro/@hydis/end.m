% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% End overloaded for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function out = end(A,k,n)
xx = A.ds;  
if n==1  
    out = length(xx(:));
else
    out = size(xx,k);
end
