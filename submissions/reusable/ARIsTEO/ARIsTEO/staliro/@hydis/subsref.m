% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% SUBSREF Subreferencing for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function out = subsref(in,S)

if length(S)>1
    error('hydis: multiple indexing not allowed')
end
if strcmp(S.type,'()')
    out = hydis(subsref(in.dl,S),subsref(in.ds,S));
else
    error('hydis: Only arrays are supported')
end
