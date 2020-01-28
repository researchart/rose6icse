% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% map2line - maps a hydis array to a double array.
%
% USAGE:
%   x = map2line(h,a);
% 
% The mapping is done using the inverse logit function and the path 
% distance h.dl, i.e.,
%
%   x = h.dl + 2*(2*exp(h.ds/a)/(1+exp(h.ds/a))-1)
%
% where a is a scaling factor. If the scaling factor is not provided, then
% a = 1. The scaling factor is necessary since a value of h.ds above 40
% already gives the upper bound 1 for the inverse logit function. 
% 
% INPUTS:
%   h - hydis value
%   a - the scaling factor
%
% OUTPUTS:
%   x - the output is a double precision floating point value
%

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.09.18

function out_val = map2line(in_val,scl)
if nargin==1
    scl=1;
end
ds = in_val.ds/scl;
id_p = in_val>=0;
tmp_p = (2*exp(ds(id_p))./(1+exp(ds(id_p)))-1);
id_nan = isnan(tmp_p);
tmp_p(id_nan) = 1;
out_val(id_p) = in_val.dl(id_p)+tmp_p;
id_m = in_val<0;
tmp_m = (2*exp(ds(id_m))./(1+exp(ds(id_m)))-1);
id_nan = isnan(tmp_m);
tmp_m(id_nan) = -1;
out_val(id_m) = in_val.dl(id_m)+tmp_m;
end
