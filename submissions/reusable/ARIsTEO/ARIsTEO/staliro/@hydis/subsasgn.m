% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% SUBSASGN Implements subscripted assignments for hydis class
%
% EXAMPLE:
%   a(i,:) = b

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function aa = subsasgn(aa,S,bb)

if ~isa(bb,'hydis')
      error('hydis: Cannot assign an non-hydis object to a hydis object.');
else
    if length(S)>1
        error('hydis: multiple indexing not allowed')
    end
    if strcmp(S.type,'()')
        aa.dl = subsasgn(aa.dl,S,bb.dl);
        aa.ds = subsasgn(aa.ds,S,bb.ds);
    else
        error('Only arrays are supported in hydis')
    end
end
