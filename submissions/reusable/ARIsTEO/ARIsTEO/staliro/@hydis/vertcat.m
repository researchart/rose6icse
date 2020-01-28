% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Vertical concatenation overloaded for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function out = vertcat(varargin)
out = hydis(varargin{1});
for ii=2:nargin
    tmp = hydis(varargin{ii});
    out.ds = [out.ds; tmp.ds];
    out.dl = [out.dl; tmp.dl];
end
