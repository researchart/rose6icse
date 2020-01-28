% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Get function for hydis class
%   get(hd,1) returns the 1st member of the pair
%   get(hd,2) returns the 2nd member of the pair
%

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function out = get(obj,id)

if nargin==1
    out = [obj.dl, obj.ds];
elseif id==1
    out = obj.dl;
elseif id==2
    out = obj.ds;
else
    error('hydis:get:Option not supported')
end
