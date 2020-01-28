% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [nearest_point_on_s, tmin, dmin, bo, ix_dmin] = DistTrajToUnsafe(s, unsafe)
% INPUTS
%   s       Trajectory = [ti; state(ti)]-by-nb_of_samples
%   unsafe  object of class unsafeset
% OUTPUTS
%   [nearest_point_on_s, tmin, dmin, bo, ix_dmin]
%
% If s enters B, then tmin is the TIME OF ENTRY, not the time at which s is
% "deepest" in B


nbpnts = size(s, 2);
dd = zeros(nbpnts,1);
bproj = zeros(size(s,1)-1, nbpnts);

for i=1:nbpnts
    xx = s(2:end, i);
    [dd(i), bproj(:,i)] = unsafe.distance_to_me(xx);
end
[dmin, ix_dmin] = min(dd);
bo = bproj(:, ix_dmin);
nearest_point_on_s = s(2:end, ix_dmin);
tmin = s(1,ix_dmin);

