% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Sample uniformly at random from an ellipsoid
% 
% INPUTS
%   ell - the ellipsoid
%   nop - the number of sampled points to be returned

% (C) G. Fainekos 2010 - ASU

function out = sampleEllipsoid(ell,nop)
if isa(ell,'ellipsoid')
    [q,Q] = parameters(ell);
else
    Q = ell;
end
[V,D] = eig((Q),'nobalance');
nn = length(Q);
R = sqrtm(D)*V';
out = zeros(nop,nn);
for ii = 1:nop
    x = (0.5-rand(1,nn))*2;
    x = (x/norm(x))*(0.5-rand(1))*2;
    out(ii,:) = q'+(R'*x')';
end
