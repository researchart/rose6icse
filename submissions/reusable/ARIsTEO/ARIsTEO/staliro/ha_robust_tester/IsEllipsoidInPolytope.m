% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Note: need to check the zero bounds

function out = IsEllipsoidInPolytope(cc,dd,e0,MM,rr)
[noc,nos,nod] = size(cc);
if nod~=1 
    error('The code right now does not support unions of polytopes in the guard sets');
end
dist = inf;
ii = 0;
while dist>1.e-11 %%% potential problem?
    ii = ii+1;
    if ii>noc
        out = 1;
        return
    end
    dist = DistancePolytopeEllipsoid(-cc(ii,:),-dd(ii),e0,MM,rr);
end
out = 0;
